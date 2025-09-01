variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR for the existing VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Owner = "mohan"
    Env   = "dev"
  }
}
