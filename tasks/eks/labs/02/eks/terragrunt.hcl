include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.17.4"

  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {

cluster_name    = "my-cluster"
  cluster_version = "1.28"

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
  }

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.subnets_pub
  control_plane_subnet_ids = dependency.vpc.outputs.subnets_pub

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t3.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t3.large"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.large"
            weighted_capacity = "1"
          },
        ]
      }
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.large", "t3.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::654570355225:user/viktarm"
      username = "viktarm"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "654570355225"
  ]

  tags = local.vars.locals.tags





  region = local.vars.locals.region
  aws    = local.vars.locals.aws
  prefix = local.vars.locals.prefix
  vpc_id = dependency.vpc.outputs.vpc_id
  eks    = {
    version                      = "1.24"
    cloudwatch_retention_in_days = "30"
    allow_cidrs                  = ["0.0.0.0/0"]
    addons                       = {
      vpc-cni = {
        version           = "v1.12.2-eksbuild.1"
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {
        version           = "v1.24.9-eksbuild.1"
        resolve_conflicts = "OVERWRITE"
      }
      coredns = {
        version           = "v1.8.7-eksbuild.3"
        resolve_conflicts = "OVERWRITE"
      }
    }
    node_group = {

      default = {
        ec2_types     = ["t3.medium"]
        capacity_type = "SPOT"
        desired_size  = "2"
        max_size      = "2"
        min_size      = "1"
        disk_size     = "20"
        labels        = {
          work_type = "default"
          cost_type = "devops"
        }
      }

    }


  }

}
