provider "aws" {
  version = "~> 1.22"
  region  = "${local.region}"
}

module "vpc" {
  source             = "./src/modules/vpc"

  name               = "${local.environment}"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${local.availability_zones}"
  environment        = "${local.environment}"
}

module "security_groups" {
  source      = "./src/modules/security-groups"

  cluster_name= "${local.environment}"
  vpc_id      = "${module.vpc.id}"
  environment = "${local.environment}"
  cidr        = "${var.cidr}"
}

module "iam" {
  source = "./src/modules/iam"

  environment            = "${local.environment}"
  policy_arn_eks_cni     = "${var.policy_arn_eks_cni}"
  policy_arn_eks_service = "${var.policy_arn_eks_service}"
  policy_arn_ecr_read    = "${var.policy_arn_ecr_read}"
  policy_arn_eks_cluster = "${var.policy_arn_eks_cluster}"
  policy_arn_eks_worker  = "${var.policy_arn_eks_worker}"
}

module "eks" {
  source                 = "./src/modules/eks"

  cluster_name           = "${local.environment}"
  role_arn               = "${module.iam.role_arn_eks_basic_masters}"
  cluster_subnets        = "${module.vpc.external_subnets}"
  sg_id_cluster          = "${module.security_groups.sg_id_masters}"
}

module "worker" {
  source = "./src/modules/worker"

  environment                   = "${local.environment}"
  region                        = "${local.region}"
  instance_type                 = "${var.k8s_instance_type}"
  max_pods                      = "${var.k8s_max_pods_per_instance}"
  asg_default_cooldown          = "${var.k8s_asg_default_cooldown}"
  asg_default_capacity          = "${var.k8s_asg_default_capacity}"
  asg_max_size                  = "${var.k8s_asg_max_size}"
  asg_min_size                  = "${var.k8s_asg_min_size}"
  # Use module output to wait for masters to create.
  cluster_name                  = "${module.eks.cluster_id}"
  instance_profile_name_workers = "${module.iam.instance_profile_name_workers}"
  worker_subnets                = "${module.vpc.internal_subnets}"
  sg_id_workers                 = "${module.security_groups.sg_id_workers}"
}

data "aws_availability_zones" "available" {}

locals {
  #assumes a workspace name like env_region eg: dev_eu-west-1
  region = "${element(split("_", terraform.workspace), 3)}"
  environment = "${element(split("_", terraform.workspace), 2)}"

  #work around the issue:
  #because us-east-1a, the targeted availability zone, does not currently have sufficient capacity to support the cluster. Retry and choose from these availability zones: us-east-1b, us-east-1c, us-east-1d status code: 400
  #this will likely need to become a map as more eks regions become available
  first_az = "${local.region == "us-east-1" ? "${data.aws_availability_zones.available.names[1]}" : "${data.aws_availability_zones.available.names[0]}"}"
  second_az = "${local.region == "us-east-1" ? "${data.aws_availability_zones.available.names[2]}" : "${data.aws_availability_zones.available.names[1]}"}"
  third_az = "${local.region == "us-east-1" ? "${data.aws_availability_zones.available.names[3]}" : "${data.aws_availability_zones.available.names[2]}"}"

  availability_zones = [
    "${local.first_az}",
    "${local.second_az}",
    "${local.third_az}"
  ]

### kubecfg
  kubeconfig-aws-1-10 = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.endpoint}
    certificate-authority-data: ${module.eks.kubeconfig-certificate-authority-data}
  name: "${module.eks.cluster_id}"
contexts:
- context:
    cluster: "${module.eks.cluster_id}"
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "${module.eks.cluster_id}"

KUBECONFIG
}

locals {
  worker_iam_role_arn  = <<ROLEARN

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.iam.role_arn_eks_basic_workers}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

ROLEARN
}

