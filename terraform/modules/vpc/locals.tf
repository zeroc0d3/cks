locals {
  item_id = "${var.aws}.${var.prefix}.vpc"
  subnets_az = [
    for x in aws_subnet.subnets_pub :
  "${x.id}=${x.availability_zone}"]
  subnets_az_cmdb = join(",", local.subnets_az)
  tags_app = {
    "Name"     = "${var.aws}-${var.prefix}-${var.app_name}"
    "app_name" = var.app_name
  }
  tags_all = merge(var.tags_common, local.tags_app)
  subnets_pub=[
    for x in aws_subnet.subnets_pub :
     "${x.id}"]

  az_ids=[
    for x in aws_subnet.subnets_pub :
     "${x.availability_zone_id}"]
}
