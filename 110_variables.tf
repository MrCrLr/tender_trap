###################################
# Terraform Input Variables
###################################

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for both public and private subnets"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "ssh_ingress_ip" {
  description = "Your public IP address to allow SSH access to management port"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance type"
  type        = map(string)
}

variable "key_pair_name" {
  description = "Key pair name to use for SSH access"
  type        = string
}
