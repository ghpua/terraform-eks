// The region in which the infra lives.
output "region" {
  value = "${local.region}"
}

// Comma separated list of internal subnet IDs.
output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

// Comma separated list of external subnet IDs.
output "external_subnets" {
  value = "${module.vpc.external_subnets}"
}

// The environment of the stack, e.g "prod".
output "environment" {
  value = "${local.environment}"
}

// The VPC availability zones.
output "availability_zones" {
  value = "${module.vpc.availability_zones}"
}

// The VPC security group ID.
output "vpc_security_group" {
  value = "${module.vpc.security_group}"
}

// The VPC ID.
output "vpc_id" {
  value = "${module.vpc.id}"
}

// Comma separated list of internal route table IDs.
output "internal_route_tables" {
  value = "${module.vpc.internal_rtb_id}"
}

output "external_route_tables" {
  value = "${module.vpc.external_rtb_id}"
}

output "endpoint" {
  description = "Endpoint of the cluster."
  value       = "${module.eks.endpoint}"
}

output "cluster_id" {
  description = "The name of the cluster."
  value       = "${module.eks.cluster_id}"
}

output "kubeconfig-aws-1-10" {
  description = "Kubeconfig to connect to the cluster."
  value       = "${local.kubeconfig-aws-1-10}"
}

output "role_arn_eks_basic_workers" {
  description = "ARN of the eks-basic-workers role."
  value       = "${local.worker_iam_role_arn}"
}
