variable "vpc_id" {
  description = "ID of the VPC to deploy the cluster to."
  type        = "string"
}

variable "cidr" {
  description = "CIDR block for internal security groups."
}

variable "cluster_name" {
  description = "Name of the cluster. For tagging."
  type        = "string"
}

variable "environment" {
  description = "Name of the environment, e.g. dev, prod, etc."
  type        = "string"
}
