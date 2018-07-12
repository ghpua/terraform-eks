resource "aws_autoscaling_group" "eks_workers" {
  name = "eks-workers-${var.environment}"

  launch_configuration = "${aws_launch_configuration.eks_workers.name}"

  default_cooldown = "${var.asg_default_cooldown}"

  desired_capacity = "${var.asg_default_capacity}"
  max_size         = "${var.asg_max_size}"
  min_size         = "${var.asg_min_size}"

  vpc_zone_identifier = ["${var.worker_subnets}"]

  tag {
    key   = "Name"
    value = "${var.cluster_name}-worker"

    propagate_at_launch = true
  }

  tag {
    key   = "kubernetes.io/cluster/${var.cluster_name}"
    value = "owned"

    propagate_at_launch = true
  }
}

data "aws_ami" "k8sworker" {
    most_recent = true

    filter {
        name   = "name"
        values = ["eks-worker-v*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["602401143452"]
}

resource "aws_launch_configuration" "eks_workers" {
  instance_type = "${var.instance_type}" #"t2.medium"
  image_id      = "${data.aws_ami.k8sworker.id}" #ami-73a6e20b"

  security_groups = ["${var.sg_id_workers}"]

  # No ssh for now. Shouldn't be necessary
  # key_name = ""

  iam_instance_profile        = "${var.instance_profile_name_workers}"
  associate_public_ip_address = false
  user_data                   = "${data.template_file.user_data.rendered}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    aws_region   = "${var.region}"
    cluster_name = "${var.cluster_name}"

    #This assumes 3 eni's get deployed. Default seems to be 2: Hardcoded to 17 which is the max for t2.medium
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI
    #kubectl get pods --all-namespaces
    max_pods = "${var.max_pods}"
  }
}
