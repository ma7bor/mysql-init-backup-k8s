#!/bin/bash

# Define the namespace for backups
BACKUP_NAMESPACE="ams-backup"

# Function to delete a resource by YAML file
delete_yaml() {
    local yaml_file=$1
    local namespace=$2

    if [ -f "$yaml_file" ]; then
        echo "Deleting resources from $yaml_file in namespace $namespace..."
        microk8s kubectl delete -f "$yaml_file" -n "$namespace"
        if [ $? -ne 0 ]; then
            echo "Failed to delete resources from $yaml_file"
            exit 1
        fi
    else
        echo "File $yaml_file does not exist"
        exit 1
    fi
}

# Delete CronJobs for backups and cleanup
delete_yaml "backup/CronJobBackup.yaml" $BACKUP_NAMESPACE
delete_yaml "backup/CleanupOldBackups.yaml" $BACKUP_NAMESPACE

# Delete the restore job
delete_yaml "backup/RestoreLastBackup.yaml" $BACKUP_NAMESPACE

# Delete Persistent Volume and Persistent Volume Claim
delete_yaml "backup/PvPvc.yaml" $BACKUP_NAMESPACE

# Delete the backup namespace
echo "Deleting namespace $BACKUP_NAMESPACE..."
microk8s kubectl delete namespace $BACKUP_NAMESPACE
if [ $? -ne 0 ]; then
    echo "Failed to delete namespace $BACKUP_NAMESPACE"
    exit 1
fi

echo "Backup system cleanup completed successfully!"
