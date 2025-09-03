variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "tags" {
  description = "Map of tags to apply"
  type        = map(string)
  default = {
    Owner = "mohan"
    Env   = "dev"
  }
}


variable "tags+" {
  description = "Map of tags to apply"
  type        = map(string)
  default = {
    Owner = "mohan"
    Env   = "dev"
  }
}
