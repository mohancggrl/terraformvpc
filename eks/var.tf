variable "vpc_id" {
  description = "Existing VPC ID where EKS will be created"
  type        = string
  default     = "vpc-087620dda1de1d626"
}

# variable "region" {
#   description = "region"
#   type        = string
#   default     = "us-west-2"
# }

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
  default     = ["subnet-0a97aa2f689eead8d", "subnet-09f8987f560258c68"]
}

# -------------------------------------------------------------------
# Kubernetes Version
# -------------------------------------------------------------------
variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}
