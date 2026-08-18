variable "aws_region" {
  description = "AWS region in which the experiment is deployed."
  type        = string
  default     = "ap-south-1"
}

variable "availability_zone" {
  description = "Availability Zone for both experiment subnets, for example ap-south-1a."
  type        = string
  default     = "ap-south-1a"
}

variable "project_name" {
  description = "Short prefix used in AWS resource names."
  type        = string
  default     = "spm-exp2"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase letters, digits, or hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the experiment VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private database subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_cidr" {
  description = "Your current public IPv4 address in CIDR notation. Only this range may SSH to the web tier."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid CIDR and must not be 0.0.0.0/0. Use your public IP with /32."
  }
}

variable "key_pair_name" {
  description = "Existing EC2 key-pair name in aws_region. The private .pem file is never stored in Terraform."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for an Amazon Linux web/database instance in aws_region."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "ami_id must look like an AWS AMI ID, for example ami-0123456789abcdef0."
  }
}

variable "instance_type" {
  description = "Free Tier eligible EC2 instance type used for all three virtual machines."
  type        = string
  default     = "t3.micro"
}

variable "web_count" {
  description = "Number of identical web VMs. Set this to 3 for the reusability/scaling test."
  type        = number
  default     = 2

  validation {
    condition     = var.web_count >= 1 && var.web_count <= 5 && floor(var.web_count) == var.web_count
    error_message = "web_count must be a whole number from 1 to 5."
  }
}
