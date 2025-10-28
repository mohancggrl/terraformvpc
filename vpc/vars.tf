variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "name" {
  description = "CIDR for the VPC"
  type        = string
  default     = "devil"
}

variable "tags" {
  description = "Map of tags to apply"
  type        = map(string)
  default = {
    Owner = "mohan"
    Env   = "dev"
  }
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}