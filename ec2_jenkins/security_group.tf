# -------------------------------------------------------------------
# Data sources - Get VPC created earlier
# -------------------------------------------------------------------
# data "aws_vpc" "selected" {
#   filter {
#     name   = "tag:Name"
#     values = ["${var.name}-vpc"]
#   }
# }
# -------------------------------------------------------------------
# Security Group (All Ports Open)
# -------------------------------------------------------------------
resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Security group for Jenkins - all ports open"
  vpc_id      = data.aws_vpc.selected.id

  # Allow ALL inbound traffic
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALL outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg" })
}

# -------------------------------------------------------------------
# Output
# -------------------------------------------------------------------
output "jenkins_security_group_id" {
  description = "Security group ID for Jenkins"
  value       = aws_security_group.sg.id
}
