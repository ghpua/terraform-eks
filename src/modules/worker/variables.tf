variable "instance_type" {
  description = "AWS instance type"
  type = "string"
}

variable "max_pods" {
  description = "Maximum number of pods that should be run on an instance"
  type = "string"
}

variable "environment" {
  description = "Cluster environment name"
  type = "string"
}

variable "region" {
  description = "AWS region"
  type = "string"
}


variable "worker_subnets" {
  description = "Subnets to deploy the workers in to."
  type        = "list"
}

variable "cluster_name" {
  description = "Name of the cluster to add the workers to."
  type        = "string"
}

variable "sg_id_workers" {
  description = "Security group ID for the workers."
  type        = "string"
}

variable "instance_profile_name_workers" {
  description = "Name of the workers instance profile"
  type        = "string"
}
