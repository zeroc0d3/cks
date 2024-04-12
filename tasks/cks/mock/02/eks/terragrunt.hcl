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
  cluster_name    = "stage-localize"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }

  }

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
#  control_plane_subnet_ids = []

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

#  access_entries = {
#    # One access entry with a policy associated
#    example = {
#      kubernetes_groups = []
#      principal_arn     = "arn:aws:iam::123456789012:role/something"
#
#      policy_associations = {
#        example = {
#          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#          access_scope = {
#            namespaces = ["default"]
#            type       = "namespace"
#          }
#        }
#      }
#    }
#  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

cluster_service_ipv4_cidr="10.0.0.0/16"
cloudwatch_log_group_retention_in_days= 14
cloudwatch_log_group_class="INFREQUENT_ACCESS"
cloudwatch_log_group_tags=  {

  Environment = "dev"
    Terraform   = "true"
}


}

#  https://github.com/spotinst/terraform-spotinst-ocean-aws-k8s/blob/v1.3.0/examples/complete_from_eks_module/main.tf