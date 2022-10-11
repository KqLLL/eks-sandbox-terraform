####### cni_irsa
module "cert_manager_irsa_role" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                    = "~> 5.3.0"
  role_name                  = "${var.cluster_name}.cert-manager-controller"
  attach_cert_manager_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}
