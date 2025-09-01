#!/bin/bash

# List of Terraform module folders
folders=("vpc" "security_group" "ec2")

for folder in "${folders[@]}"; do
    echo "----------------------------"
    echo "Processing folder: $folder"
    echo "----------------------------"
    
    cd "$folder" || { echo "Folder $folder not found! Skipping."; continue; }

    terraform init -input=false
    terraform apply -auto-approve

    cd ..
done
