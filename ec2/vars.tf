variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "bastion_subnet_cidr" {
  description = "CIDR block for bastion subnet"
  type        = string
  default     = "10.0.0.0/26"
}

variable "app_subnet_1_cidr" {
  description = "CIDR block for first app subnet"
  type        = string
  default     = "10.0.0.128/26"
}

variable "app_subnet_2_cidr" {
  description = "CIDR block for second app subnet"
  type        = string
  default     = "10.0.0.192/26"
}

variable "bastion_sg_name" {
  description = "Name of the bastion security group"
  type        = string
  default     = "bastion-sg"
}

variable "app_sg_name" {
  description = "Name of the app security group"
  type        = string
  default     = "app-sg"
}

variable "bastion_ami" {
  description = "AMI ID for bastion server"
  type        = string
  default     = "ami-05b85154f69f6bcb3" # Example Amazon Linux 2
}

variable "app_ami" {
  description = "AMI ID for app servers"
  type        = string
  default     = "ami-07378eee6a8e82f97" # Example Amazon Linux 2
}

variable "bastion_instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = "mumbai"
}

variable "app_server_1_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "MUMBAINODE1"
}

variable "app_server_2_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "MUMBAINODE2"
}

variable "app_server_3_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "MUMBAINODE2"
}