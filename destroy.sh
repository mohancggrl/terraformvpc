#!/bin/bash
set -e  # Exit if any command fails

# Destroy order: ec2 -> security_group -> vpc
folders=("ec2" "security_group" "vpc")

for folder in "${folders[@]}"; do
    echo "----------------------------------------"
    echo "Destroying: $folder"
    echo "----------------------------------------"

    if [ -d "$folder" ]; then
        cd "$folder"
        terraform init -input=false
        terraform destroy -auto-approve
        cd ..
    else
        echo "❌ Folder $folder not found! Skipping..."
    fi
done
