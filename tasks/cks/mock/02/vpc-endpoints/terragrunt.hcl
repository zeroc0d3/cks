dependencies {
  config_path  = ["../vpc"]
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc//modules/vpc-endpoints?ref=v5.6.0"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  security_group_ids = [dependency.vpc.outputs.vpc_default_security_group_id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      tags            = { "Name" = "s3-vpc-endpoint" }
      subnet_ids      = dependency.vpc.outputs.private_subnets_ids
      route_table_ids = dependency.vpc.outputs.private_route_table_ids
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      tags            = { "Name" = "dynamodb-vpc-endpoint" }
      subnet_ids      = dependency.vpc.outputs.private_subnets_ids
      route_table_ids = dependency.vpc.outputs.private_route_table_ids
    }
  }
}

