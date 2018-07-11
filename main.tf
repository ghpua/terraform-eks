provider "aws" {
  version = "~> 1.22"
  region  = "${var.region}"
}

module "vpc" {
  source             = "./src/modules/vpc"

  name               = "${terraform.workspace}"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
  environment        = "${terraform.workspace}"
}

module "security_groups" {
  source      = "./src/modules/security-groups"

  cluster_name= "${terraform.workspace}"
  vpc_id      = "${module.vpc.id}"
  environment = "${terraform.workspace}"
  cidr        = "${var.cidr}"
}

module "iam" {
  source = "./src/modules/iam"

  policy_arn_eks_cni     = "${var.policy_arn_eks_cni}"
  policy_arn_eks_service = "${var.policy_arn_eks_service}"
  policy_arn_ecr_read    = "${var.policy_arn_ecr_read}"
  policy_arn_eks_cluster = "${var.policy_arn_eks_cluster}"
  policy_arn_eks_worker  = "${var.policy_arn_eks_worker}"
}

module "eks" {
  source                 = "./src/modules/eks"

  cluster_name           = "${terraform.workspace}"
  role_arn               = "${module.iam.role_arn_eks_basic_masters}"
  cluster_subnets        = "${module.vpc.external_subnets}"
  sg_id_cluster          = "${module.security_groups.sg_id_masters}"
}

module "worker" {
  source = "./src/modules/worker"

  # Use module output to wait for masters to create.
  cluster_name                  = "${module.eks.cluster_id}"
  instance_profile_name_workers = "${module.iam.instance_profile_name_workers}"
  worker_subnets                = "${module.vpc.internal_subnets}"
  sg_id_workers                 = "${module.security_groups.sg_id_workers}"
}

### kubecfg

locals {
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

