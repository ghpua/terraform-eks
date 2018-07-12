variable "k8s_instance_type" {
  description = "AWS instance type"
  type = "string"
}

variable "k8s_max_pods_per_instance" {
  description = "Maximum number of pods that should be run on an instance"
  type = "string"
}

variable "k8s_asg_default_cooldown" {
  description = "AWS k8s_asg_default_cooldown"
  type = "string"
}

variable "k8s_asg_default_capacity" {
  description = "AWS k8s_asg_default_capacity"
  type = "string"
}
variable "k8s_asg_max_size" {
  description = "AWS k8s_asg_max_size"
  type = "string"
}
variable "k8s_asg_min_size" {
  description = "AWS k8s_asg_min_size"
  type = "string"
}

variable "cidr" {
  description = "VPC CIDR block"
}

variable "internal_subnets" {
  description = "List of private subnets"
  type        = "list"
}

variable "external_subnets" {
  description = "List of public subnets"
  type        = "list"
}

variable "policy_arn_eks_cluster" {
  description = "ARN of the default policy: AmazonEKSClusterPolicy."
  type        = "string"
}

variable "policy_arn_eks_service" {
  description = "ARN of the default policy: AmazonEKSServicePolicy."
  type        = "string"
}

variable "policy_arn_eks_worker" {
  description = "ARN of the default policy: AmazonEKSWorkerNodePolicy"
  type        = "string"
}

variable "policy_arn_eks_cni" {
  description = "ARN of the default policy: AmazonEKS_CNI_Policy"
  type        = "string"
}

variable "policy_arn_ecr_read" {
  description = "ARN of the default policy: AmazonEC2ContainerRegistryReadOnly"
  type        = "string"
}
