#!/bin/bash

# Check if microk8s kubectl is installed
if ! command -v microk8s kubectl &> /dev/null
then
    echo "microk8s kubectl could not be found. Please install microk8s first."
    exit 1
fi

# Define the namespace
namespace="ams-app"

# Cleanup function
cleanup() {
    echo "Cleaning up resources in namespace $namespace..."
    for file in "${yaml_files[@]}"; do
        microk8s kubectl delete -f "$file" -n "$namespace"
    done
    echo "Cleanup complete."
}

# Parse command line arguments
cleanup_flag=false
verbose_flag=false

while getopts "cv" opt; do
    case $opt in
        c) cleanup_flag=true ;;
        v) verbose_flag=true ;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

if $cleanup_flag; then
    cleanup
    exit 0
fi

echo "Deployment is starting..."

# Check if the namespace exists, create it if it doesn't
if ! microk8s kubectl get namespace "$namespace" &> /dev/null
then
    echo "Namespace $namespace does not exist. Creating it..."
    microk8s kubectl create namespace "$namespace"
    if [ $? -ne 0 ]; then
        echo "Failed to create namespace $namespace"
        exit 1
    fi
else
    echo "Namespace $namespace already exists."
fi

# Define YAML files to be applied in order
yaml_files=(
    "mysql/mysql-secrets.yaml"
    "mysql/mysql-configmap.yaml"
    "mysql/mysql-pvc.yaml"
    "mysql/mysql-deployment.yaml"
    "mysql/phpmyadmin-deployment.yaml"
    # Add more files here as needed
)

# Apply each YAML file in the specified namespace
for file in "${yaml_files[@]}"
do
    if [ -f "$file" ]; then
        echo "Applying $file in namespace $namespace..."
        if $verbose_flag; then
            microk8s kubectl apply -f "$file" -n "$namespace"
        else
            microk8s kubectl apply -f "$file" -n "$namespace" &> /dev/null
        fi
        if [ $? -ne 0 ]; then
            echo "Failed to apply $file"
            exit 1
        fi
    else
        echo "File $file does not exist"
        exit 1
    fi
done

echo "All specified YAML files have been applied successfully in namespace $namespace."
echo "Deployment complete."