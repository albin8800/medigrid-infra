variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "ap-southeast-2" # Matches your AWS console region (Sydney)
}

variable "environment" {
  description = "Deployment environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Base CIDR block IP range for the MediGrid VPC"
  type        = string
  default     = "10.0.0.0/16" # Gives 65,536 private IP addresses
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (Internet-facing)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (Databases & Internal Services)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}
