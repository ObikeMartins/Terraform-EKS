provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # ✅ Upgrade to the latest version

  name = "martins-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true  # ✅ Ensure NAT Gateway is enabled if needed
  enable_vpn_gateway = false # ✅ Disable VPN Gateway if not needed

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.20.0"  # Use the latest stable version
  cluster_name    = "my-cluster"
  cluster_version = "1.27"  # Upgrade EKS version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets  # ✅ Corrected argument

  eks_managed_node_groups = {
    eks_nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Name        = "my-cluster"
    Terraform   = "true"
    Environment = "dev"
  }
}
