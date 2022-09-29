output "ci_irsa_role_arn" {
  value = module.vpc_cni_irsa_role.iam_role_arn
}