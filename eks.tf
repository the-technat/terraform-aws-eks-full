module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  cluster_addons = {
    coredns = {
      most_recent = true
    }
  }

  # Networking
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_service_ipv4_cidr      = var.service_cidr
  cluster_endpoint_public_access = true
  node_security_group_additional_rules = {
    ingress_self_all = { # cilium requires many ports to be open node-by-node
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # KMS
  attach_cluster_encryption_policy = false
  create_kms_key                   = false
  cluster_encryption_config        = {}

  # IAM
  manage_aws_auth_configmap = true
  aws_auth_users            = var.aws_auth_users

  // settings in this block apply to all nodes groups
  eks_managed_node_group_defaults = {
    # Compute
    capacity_type  = var.capacity_type
    ami_type       = "AL2_${var.arch}"
    instance_types = var.instance_types
    ami_id         = data.aws_ami.eks_default.image_id
    desired_size   = var.desired_count

    # IAM
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    }

    // required since we specify the AMI to use
    // otherwise the nodes don't join
    // setting also assume the default eks image is used
    enable_bootstrap_user_data = true
  }

  eks_managed_node_groups = {
    workers-a = {
      name       = "${var.cluster_name}-a"
      subnet_ids = [module.vpc.private_subnets[0]]
    }
    workers-b = {
      name       = "${var.cluster_name}-b"
      subnet_ids = [module.vpc.private_subnets[1]]
    }
    workers-c = {
      name       = "${var.cluster_name}-c"
      subnet_ids = [module.vpc.private_subnets[2]]
    }
  }

  tags = var.tags
}