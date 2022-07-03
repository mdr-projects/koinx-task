# Variables
#==========

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  default = "10.0.0.0/16"
}

variable "AWS_EC2_Region" {
    description = "EC2 region"
    default = "us-west-2"
}

variable "instance_type_ec2" {
    description = "EC2 instance type"
    default = "t2.medium"
}

variable "AMI" {
    description = "AMI ID"
    type = map
    default = {
        us-west-2 = "ami-0d70546e43a941d70"
    }
}

variable "key_name" {
    description = "Key pair name"
    default = "koinx"
}

variable "instance_type_eks" {
  description = "EKS Instance Types"
  default = "t3.medium"
}

variable "capacity_type_eks" {
  description = "EKS capacity type"
  default = "SPOT"
}

variable "desired_size" {
  description = "Desired number of Nodes"
  default = 1
}

variable "max_size" {
  description = "Maximum number of nodes that can be in a cluster"
  default = 2
}

variable "min_size" { 
  description = "Minimum number of nodes that should be in a cluster"
  default = 1
}

variable "max_unavailable" {
  description = " Maximum number of nodes that can be unavailable in a cluster"
  default = 1
}

