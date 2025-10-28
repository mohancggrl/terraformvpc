# -------------------------------------------------------------------
# Data sources - VPC, Subnets, and Security Group
# -------------------------------------------------------------------

# Get the VPC by tag name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}-vpc"]
  }
}

# Get public subnets for Jenkins instance placement
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# -------------------------------------------------------------------
# Jenkins EC2 Instance (Red Hat RHEL, t3.small)
# -------------------------------------------------------------------
resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # -----------------------------
  # User data: Jenkins + Docker setup
  # -----------------------------
  user_data = <<-EOF
    #!/bin/bash
    set -e
    set -o pipefail

    echo "---- Updating system ----"
    dnf update -y

    echo "---- Installing base packages ----"
    dnf install -y wget git curl yum-utils device-mapper-persistent-data lvm2

    echo "---- Installing Java 17 and Maven ----"
    dnf install -y java-17-openjdk-devel maven

    echo "---- Java version ----"
    java --version

    # ------------------------------------------------------------
    # Jenkins installation
    # ------------------------------------------------------------
    echo "---- Adding Jenkins repository ----"
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    echo "---- Installing Jenkins ----"
    dnf install -y jenkins

    echo "---- Enabling and starting Jenkins ----"
    systemctl daemon-reload
    systemctl enable jenkins
    systemctl start jenkins

    # ------------------------------------------------------------
    # Docker installation
    # ------------------------------------------------------------
    echo "---- Adding Docker CE repository ----"
    dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

    echo "---- Installing Docker Engine and tools ----"
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "---- Enabling and starting Docker ----"
    systemctl enable --now docker

    # ------------------------------------------------------------
    # Jenkins + Docker integration
    # ------------------------------------------------------------
    echo "---- Configuring Jenkins user to use Docker ----"
    usermod -s /bin/bash jenkins
    usermod -aG docker jenkins

    # Restart Jenkins to apply group membership
    systemctl restart jenkins

    echo "---- Setup complete! ----"
    echo "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
  EOF

  tags = merge(var.tags, { Name = "${var.name}-instance" })
}

# -------------------------------------------------------------------
# Outputs
# -------------------------------------------------------------------
output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}
# -------------------------------------------------------------------
# resource "aws_instance" "jenkins" {
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   subnet_id                   = data.aws_subnets.public.ids[0]
#   vpc_security_group_ids      = [aws_security_group.sg.id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name
#   tags = merge(var.tags, { Name = "${var.name}-instance" })
# }

# # -------------------------------------------------------------------
# # Outputs
# # -------------------------------------------------------------------
# output "jenkins_public_ip" {
#   description = "Public IP of Jenkins EC2 instance"
#   value       = aws_instance.jenkins.public_ip
# }
