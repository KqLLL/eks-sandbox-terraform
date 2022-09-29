locals {
  region = "us-east-2"

  cluster_name    = "sandbox"
  cluster_version = "1.23"

  instance_types = ["t3.medium", "t3a.medium"]

  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition
}