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

variable "server_username" {
  description = "userName of the service user"
  type = string
  default = "mydevops"
}
variable "ssh_public_key" {
  description = "public key of service user"
  type = string
  default = ""
}

variable "server_hostname" {
  description = "Hostname for the Linux server"
  type        = string
  default     = "AGENT01"
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}