import os
import subprocess

# Destroy order: ec2 -> security_group -> vpc
folders = ["ec2", "security_group", "vpc"]

for folder in folders:
    print("\n" + "-"*40)
    print(f"Destroying: {folder}")
    print("-"*40)

    if os.path.isdir(folder):
        os.chdir(folder)
        subprocess.run(["terraform", "init", "-input=false"], check=True)
        subprocess.run(["terraform", "destroy", "-auto-approve"], check=True)
        os.chdir("..")
    else:
        print(f"❌ Folder {folder} not found! Skipping...")
