#!/bin/bash

# List of directories to process
DIRS=("vpc" "security_group" "ec2")

for dir in "${DIRS[@]}"; do
    echo "=============================="
    echo "Processing directory: $dir"
    echo "=============================="
    
    cd "$dir" || { echo "❌ Failed to enter directory $dir"; exit 1; }
    
    terraform init -input=false
    if [ $? -ne 0 ]; then
        echo "❌ terraform init failed in $dir"
        exit 1
    fi
    
    terraform plan -input=false
    if [ $? -ne 0 ]; then
        echo "❌ terraform plan failed in $dir"
        exit 1
    fi
    
    cd ..
done

echo "✅ All modules processed successfully."