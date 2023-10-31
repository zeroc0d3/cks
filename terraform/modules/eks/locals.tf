
locals {
  subnets            = var.eks.subnets
  availability_zones = data.aws_availability_zones.available.zone_ids

}
