variable "vpc_id" {
  description = "Existing VPC ID where EKS will be created"
  type        = string
  default     = "vpc-0f63d726e68c16adc"
}

variable "region" {
  description = "region"
  type        = string
  default     = "us-west-2"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
  default     = ["subnet-0739bbec0973aec7e", "subnet-0dec17319f6c9365b"]
}