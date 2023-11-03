resource "aws_ec2_tag" "example" {
  for_each    = toset(var.eks.subnets)
  resource_id = each.value
  key         = "example_key"
  value       = "example value"
}