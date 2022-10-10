module "sqs_operator_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.3.0"
  role_name = "${var.cluster_name}.sqs-controller"
  role_policy_arns = {
    "${var.cluster_name}.sqs-controller" : "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  }
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["ack-system:ack-sqs-controller-sa"]
    }
  }
}
