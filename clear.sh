#!/bin/bash

# Check if microk8s kubectl is installed
if ! command -v microk8s kubectl &> /dev/null
then
    echo "microk8s kubectl could not be found. Please install microk8s first."
    exit 1
fi

echo "Clearing is starting..."
# Define the namespace
namespace="ams-app"

# Delete all resources in the namespace, including volumes
microk8s kubectl delete all --all -n $namespace
microk8s kubectl delete configmap --all -n $namespace
microk8s kubectl delete pvc --all -n $namespace
microk8s kubectl delete pv --all -n $namespace
microk8s kubectl delete secret --all -n $namespace
microk8s kubectl delete service --all -n $namespace
microk8s kubectl delete ingress --all -n $namespace

# Delete the namespace itself (if desired)
# microk8s kubectl delete namespace $namespace

echo "The namespace $namespace has been cleared successfully, including volumes."