variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "name" {
  description = "Name prefix for resources"
  type        = string
  default     = "devil"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Owner = "mohan"
    Env   = "dev"
  }
}

variable "ami_id" {
  description = "AMI ID for Jenkins EC2 instance (Red Hat RHEL)"
  type        = string
  default     = "ami-0357fd8270bb3203e"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = "mohan"
}

variable "app_server_1_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "MUMBAINODE1"
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}