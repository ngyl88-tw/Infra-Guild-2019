# Provider
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

locals {
  cluster_name = var.cluster_name
}

data "aws_availability_zones" "azs" {
  state = "available"
}

# VPC and Subnets

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = "192.168.0.0/20"
  azs                  = data.aws_availability_zones.azs.names
  private_subnets      = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
  public_subnets       = ["192.168.15.208/28", "192.168.15.224/28", "192.168.15.240/28"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags are required for EKS to recognise these subnets
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = local.cluster_name
  cluster_endpoint_public_access = "true"

  tags = {
    environment = local.cluster_name
  }

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  worker_groups = [
    {
      autoscaling_enabled  = true
      asg_min_size         = 2
      asg_max_size         = 2
      asg_desired_capacity = 2
      instance_type        = "t3.small"
    }
  ]

  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name,
    "--profile",
    var.aws_profile
  ]
}