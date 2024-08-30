#!/bin/bash

# Define the namespace for backups
BACKUP_NAMESPACE="ams-backup"

# Function to apply a YAML file
apply_yaml() {
    local yaml_file=$1
    local namespace=$2

    if [ -f "$yaml_file" ]; then
        echo "Applying $yaml_file in namespace $namespace..."
        microk8s kubectl apply -f "$yaml_file" -n "$namespace"
        if [ $? -ne 0 ]; then
            echo "Failed to apply $yaml_file"
            exit 1
        fi
    else
        echo "File $yaml_file does not exist"
        exit 1
    fi
}

# Create the backup namespace if it doesn't exist
microk8s kubectl get namespace $BACKUP_NAMESPACE >/dev/null 2>&1 || \
microk8s kubectl create namespace $BACKUP_NAMESPACE

# Apply Persistent Volume and Persistent Volume Claim first
apply_yaml "backup/PvPvc.yaml" $BACKUP_NAMESPACE

# Apply the CronJob for daily backups
apply_yaml "backup/CronJobBackup.yaml" $BACKUP_NAMESPACE

# Apply the CronJob for cleaning up old backups
apply_yaml "backup/CleanupOldBackups.yaml" $BACKUP_NAMESPACE

# Apply the YAML for restoring the last backup
apply_yaml "backup/RestoreLastBackup.yaml" $BACKUP_NAMESPACE

echo "Backup system configuration completed successfully!"
