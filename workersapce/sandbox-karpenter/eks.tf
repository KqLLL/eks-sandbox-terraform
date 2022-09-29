data "aws_eks_addon_version" "latest_kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

module "irsa" {
  source = "../../module/irsa"

  cluster_name        = local.cluster_name
  cluster_version     = local.cluster_version
  oidc_provider_arn   = module.eks.oidc_provider_arn
  karpenter_role_arns = [module.eks.eks_managed_node_groups["karpenter"].iam_role_arn]
}

module "eks" {
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }

    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = data.aws_eks_addon_version.latest_kube_proxy.version
    }

    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.irsa.ci_irsa_role_arn
    }
  }

  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Required for Karpenter role below
  enable_irsa = true

  # Node security group
  node_security_group_additional_rules = {
    cluster_to_node_other_ports = {
      description                   = "Cluster API to node by other ports"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }

    node_egress = {
      description = "Egress Freedom"
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "all"
      from_port   = 0
      to_port     = 65535
      type        = "egress"
    }

    node_to_node_ingress = {
      description = "Node to Node Ingress"
      protocol    = "all"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery/${local.cluster_name}" = local.cluster_name
  }

  eks_managed_node_groups = {
    karpenter = {
      instance_types        = ["t3a.large"]
      create_security_group = false

      min_size     = 0
      max_size     = 1
      desired_size = 1
    }
    subnet_ids = [module.vpc.public_subnets]

    iam_role_additional_policies = [
      # Required by Karpenter
      "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]

    tags = {
      # This will tag the launch template created for use by Karpenter
      "karpenter.sh/discovery/${local.cluster_name}" = local.cluster_name
    }
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.cluster_name}"
  role = module.eks.eks_managed_node_groups["karpenter"].iam_role_name
}
