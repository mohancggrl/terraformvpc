# -------------------------------------------------------------------
# Kubernetes Version
# -------------------------------------------------------------------
variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "eks cluster name"
  type        = string
  default     = "devil"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}