import os
import subprocess

# ----------------------------------------------------------
# User Configuration
# ----------------------------------------------------------
access_key = ""
secret_key = ""
region = "us-west-2"

# ----------------------------------------------------------
# Choose Which Modules to Run
# ----------------------------------------------------------
print("Select which Terraform module(s) to run:")
print("1. VPC only")
print("2. ec2_jenkins only")
print("3. Both (VPC + ec2_jenkins)")
module_choice = input("Enter 1, 2, or 3: ").strip()

if module_choice == "1":
    folders = ["vpc"]
elif module_choice == "2":
    folders = ["ec2_jenkins"]
elif module_choice == "3":
    folders = ["vpc", "ec2_jenkins"]  # order will be adjusted later based on action
else:
    print("❌ Invalid module choice! Exiting.")
    exit(1)

# ----------------------------------------------------------
# Choose Action
# ----------------------------------------------------------
print("\nSelect Terraform Action:")
print("1. Apply (create resources)")
print("2. Destroy (delete resources)")
choice = input("Enter 1 or 2: ").strip()

if choice not in ["1", "2"]:
    print("❌ Invalid choice! Exiting.")
    exit(1)

action = "apply" if choice == "1" else "destroy"

# Reverse order for destroy (ec2_jenkins → VPC)
if action == "destroy" and "vpc" in folders and "ec2_jenkins" in folders:
    folders.reverse()

# ----------------------------------------------------------
# Run Terraform per folder
# ----------------------------------------------------------
for folder in folders:
    print(f"\n{'-'*40}")
    print(f"Processing folder: {folder} ({action.upper()})")
    print(f"{'-'*40}")

    if not os.path.isdir(folder):
        print(f"❌ Folder {folder} not found! Skipping...")
        continue

    os.chdir(folder)

    # Terraform Init
    subprocess.run(["terraform", "init", "-input=false"], check=True)

    # Build command
    command = [
        "terraform", action,
        "-auto-approve",
        f"-var=access_key={access_key}",
        f"-var=secret_key={secret_key}",
        f"-var=region={region}"
    ]

    # Execute Terraform command
    subprocess.run(command, check=True)

    os.chdir("..")

print("\n✅ Terraform operation completed successfully!")
