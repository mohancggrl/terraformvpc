# Lookup VPC by CIDR
data "aws_vpc" "selected" {
  cidr_block = "10.0.0.0/24"
}

# 1. Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH and RDP from anywhere"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion"
  }
}

# 2. ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow access from anywhere"
  vpc_id      = data.aws_vpc.selected.id

  # Allow ALL TCP from anywhere
  ingress {
    description     = "Allow all TCP from anywhere"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg"
  }
}

# 3. App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow access from bastion-sg"
  vpc_id      = data.aws_vpc.selected.id

  # Allow SSH from Bastion SG
  ingress {
    description     = "Allow SSH from bastion-sg"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow ALL TCP from Bastion SG
  ingress {
    description     = "Allow all TCP from bastion-sg"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Allow all TCP from ALB-sg"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app"
  }
}


