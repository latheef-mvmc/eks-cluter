# Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cicd-cluster"
}

variable "cluster_version" {
  description = "Version of Kubernetes to use in the EKS cluster"
  type        = string
  default     = "1.25"
}

variable "subnet_cidr_blocks" {
  description = "List of subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of nodes in the Node Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the Node Group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of nodes in the Node Group"
  type        = number
  default     = 1
}
