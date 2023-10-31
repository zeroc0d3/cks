locals {
  region = "eu-north-1"
  aws    = "default"
  prefix = "eks-01"
  tags   = {
    "env_name"        = "eks-karpenter"
    "env_type"        = "dev"
    "manage"          = "terraform"
    "cost_allocation" = "dev"
    "city"  = "all_us"
    "team"="infra"
    "Operation"="USA"

  }
  k8_version    = "1.26.0"
  node_type     = "spot"
  instance_type = "t3.medium"
  key_name      = "cks"
  ami_id        = "ami-06410fb0e71718398"
  root_volume   = {
    type = "gp3"
    size = "15"
  }
}
