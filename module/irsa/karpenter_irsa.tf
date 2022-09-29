module "karpenter_irsa" {
  count = var.karpenter_enabled ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3.0"

  role_name                          = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_tag_key                       = "karpenter.sh/discovery/${var.cluster_name}"
  karpenter_controller_cluster_id         = var.cluster_name
  karpenter_controller_node_iam_role_arns = var.karpenter_role_arns

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}
