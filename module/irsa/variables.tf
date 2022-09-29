variable "oidc_provider_arn" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "karpenter_role_arns" {
  type    = list(string)
  default = []
}

variable "karpenter_enabled" {
  type    = bool
  default = false
}