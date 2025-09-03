# ------------------------
# Get VPC
# ------------------------
data "aws_vpc" "selected" {
  filter {
    name   = "cidr-block"
    values = [var.vpc_cidr]
  }
}

# ------------------------
# Get Subnets
# ------------------------
data "aws_subnet" "bastion_subnet" {
  filter {
    name   = "cidr-block"
    values = [var.bastion_subnet_cidr]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "app_subnet_1" {
  filter {
    name   = "cidr-block"
    values = [var.app_subnet_1_cidr]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "app_subnet_2" {
  filter {
    name   = "cidr-block"
    values = [var.app_subnet_2_cidr]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# ------------------------
# Get Security Groups
# ------------------------
data "aws_security_group" "bastion_sg" {
  filter {
    name   = "group-name"
    values = [var.bastion_sg_name]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = [var.app_sg_name]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# ------------------------
# EC2 Instances
# ------------------------
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = data.aws_subnet.bastion_subnet.id
  vpc_security_group_ids      = [data.aws_security_group.bastion_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data = <<-EOF
    <powershell>
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Refresh PATH
    $env:Path += ";$env:ALLUSERSPROFILE\\chocolatey\\bin"

    # Install Google Chrome
    choco install googlechrome -y

    # Install Git
    choco install git -y

    # Optional: Verify installations
    git --version
    (Get-Command "chrome.exe" -ErrorAction SilentlyContinue) -ne $null
    </powershell>
  EOF
  
  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "app_server_1" {
  ami                         = var.app_ami
  instance_type               = var.app_instance_type
  subnet_id                   = data.aws_subnet.app_subnet_1.id
  vpc_security_group_ids      = [data.aws_security_group.app_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data = <<-EOF
    #!/bin/bash
    HOSTNAME_VAR="${var.app_server_1_hostname}"

    # Preserve hostname across reboots
    sed -i '/preserve_hostname/d' /etc/cloud/cloud.cfg
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

    # Set the hostname immediately
    hostnamectl set-hostname "$HOSTNAME_VAR"

    # Grab the primary private IPv4 address
    PRIVATE_IP=$(hostname -I | awk '{print $1}')

    # Update /etc/hosts to map the hostname to the private IP
    if grep -q "$PRIVATE_IP" /etc/hosts; then
        sed -i "s/^$PRIVATE_IP.*/$PRIVATE_IP $HOSTNAME_VAR/" /etc/hosts
    else
        echo "$PRIVATE_IP $HOSTNAME_VAR" >> /etc/hosts
    fi

    # Install essentials and Nginx
    yum install -y wget vim unzip git nginx

    # Enable and start Nginx service
    systemctl enable nginx
    systemctl start nginx

    # Clone the GitHub repo into a temporary directory
    TMP_DIR="/tmp/nginx-site"
    rm -rf "$TMP_DIR"
    git clone https://github.com/mohancggrl/nginx.git "$TMP_DIR"

    # Deploy the site to Nginx's web root
    rm -rf /usr/share/nginx/html/*
    cp -r "$TMP_DIR"/* /usr/share/nginx/html/

    # Fix ownership and permissions for proper serving
    chown -R nginx:nginx /usr/share/nginx/html
    chmod -R 755 /usr/share/nginx/html
  EOF

  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "app_server_2" {
  ami                         = var.app_ami
  instance_type               = var.app_instance_type
  subnet_id                   = data.aws_subnet.app_subnet_2.id
  vpc_security_group_ids      = [data.aws_security_group.app_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data = <<-EOF
    #!/bin/bash
    HOSTNAME_VAR="${var.app_server_2_hostname}"

    # Preserve hostname on reboot
    sed -i '/preserve_hostname/d' /etc/cloud/cloud.cfg
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

    # Set hostname immediately
    hostnamectl set-hostname "$HOSTNAME_VAR"

    # Get private IP
    PRIVATE_IP=$(hostname -I | awk '{print $1}')

    # Add/Update /etc/hosts
    if grep -q "$PRIVATE_IP" /etc/hosts; then
        sed -i "s/^$PRIVATE_IP.*/$PRIVATE_IP $HOSTNAME_VAR/" /etc/hosts
    else
        echo "$PRIVATE_IP $HOSTNAME_VAR" >> /etc/hosts
    fi

    # Install required packages
    yum install -y git wget vim unzip httpd

    # Enable and start Apache
    systemctl enable httpd
    systemctl start httpd

    # Clone GitHub repo
    TMP_DIR="/tmp/nginx-site"
    rm -rf "$TMP_DIR"
    git clone https://github.com/mohancggrl/my_profile.git "$TMP_DIR"

    # Deploy to Apache web root
    rm -rf /var/www/html/*
    cp -r "$TMP_DIR"/* /var/www/html/

    # Set permissions
    chown -R apache:apache /var/www/html
    chmod -R 755 /var/www/html
  EOF

  tags = {
    Name = "app-server-2"
  }
}


variable "app_server_4_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "MUMBAINODE2"
}