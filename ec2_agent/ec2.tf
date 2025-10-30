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

# -------------------------------
# EC2 Instance
# -------------------------------
resource "aws_instance" "myserver" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name               = var.key_name

  # -------------------------------
  # USERDATA TEMPLATE
  # -------------------------------
  user_data = <<-EOF
    #!/bin/bash
    set -e

    USERNAME="${var.server_username}"
    SSH_KEY="${var.ssh_public_key}"
    HOSTNAME="${var.server_hostname}"

    if [ -z "$SSH_KEY" ]; then
      echo "❌ ERROR: SSH public key not provided."
      exit 1
    fi

    echo "=== Step 1: Enabling SSH password authentication ==="
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)
    sudo sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
    if ! grep -q "^UsePAM yes" /etc/ssh/sshd_config; then
      echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    fi
    sudo systemctl restart sshd
    sudo systemctl enable sshd

    echo "✅ SSH password authentication enabled."

    echo "=== Step 2: Changing hostname to '${HOSTNAME}' ==="
    sudo hostnamectl set-hostname "${HOSTNAME}"
    echo "127.0.0.1   ${HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null
    echo "✅ Hostname changed to '${HOSTNAME}'."

    echo "=== Step 3: Creating user '${USERNAME}' and adding SSH key ==="
    if id "${USERNAME}" &>/dev/null; then
      echo "User '${USERNAME}' already exists."
    else
      sudo useradd -m -s /bin/bash "${USERNAME}"
      echo "✅ User '${USERNAME}' created."
    fi

    sudo mkdir -p /home/${USERNAME}/.ssh
    echo "${SSH_KEY}" | sudo tee /home/${USERNAME}/.ssh/authorized_keys > /dev/null
    sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
    sudo chmod 700 /home/${USERNAME}/.ssh
    sudo chmod 600 /home/${USERNAME}/.ssh/authorized_keys
    echo "✅ SSH key added for user '${USERNAME}'."

    echo "=== Step 4: Granting passwordless sudo to '${USERNAME}' ==="
    sudo usermod -aG wheel ${USERNAME}
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USERNAME} > /dev/null
    sudo chmod 440 /etc/sudoers.d/${USERNAME}

    echo "=== Step 5: Installing tools ==="
    sudo dnf update -y
    sudo dnf install -y curl unzip tar gzip git dnf-plugins-core java-21-openjdk maven

    echo "✅ Java + Maven installed"

    echo "=== Step 6: Installing AWS CLI v2 ==="
    cd /tmp
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q -o awscliv2.zip
    sudo ./aws/install --update
    rm -rf /tmp/aws /tmp/awscliv2.zip

    echo "=== Step 7: Installing kubectl + Helm ==="
    curl -LO "https://dl.k8s.io/release/v1.31.1/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    sudo dnf install -y helm
    rm -f /tmp/kubectl

    echo "=== Step 8: Installing Podman (Docker replacement) ==="
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || true
    sudo dnf install -y podman podman-docker
    sudo systemctl enable --now podman.socket

    echo "✅ Setup complete for ${USERNAME} on ${HOSTNAME}"

  EOF

  tags = merge(var.tags, {
    Name = "${var.name}-instance"
  })
}


# -------------------------------------------------------------------
# Outputs
# -------------------------------------------------------------------
output "jenkins_public_ip" {
  description = "Public IP of myserver EC2 instance"
  value       = aws_instance.myserver.public_ip
}