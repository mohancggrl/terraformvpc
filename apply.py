import os
import subprocess

# Folders containing Terraform code
folders = ["vpc", "security_group", "ec2"]

for folder in folders:
    print(f"\n{'-'*40}")
    print(f"Processing folder: {folder}")
    print(f"{'-'*40}")

    if not os.path.isdir(folder):
        print(f"❌ Folder {folder} not found! Skipping...")
        continue

    os.chdir(folder)

    subprocess.run(["terraform", "init", "-input=false"], check=True)
    subprocess.run(["terraform", "apply", "-auto-approve"], check=True)

    os.chdir("..")
