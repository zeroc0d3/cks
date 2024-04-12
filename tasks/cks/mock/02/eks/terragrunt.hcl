include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}



dependency "vpc" {
  config_path = "../vpc"
}


terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks?ref=v20.8.5"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  security_group_ids = [dependency.vpc.outputs.default_security_group_id]
}

