# Terraform-EKS
Creating an Elastic Kubernetes Service (EKS) Cluster on AWS using Terraform can be broken down into a series of steps. Here's a comprehensive guide with clear instructions for each part of the process:

### Prerequisites
1. **AWS Account**: Ensure you have an active AWS account.
2. **Terraform Installed**: Install Terraform on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
3. **AWS CLI Installed**: Install the AWS CLI and configure it with your AWS credentials.
   ```bash
   aws configure
   ```

### Step 1: Set Up Terraform Configuration Files
1. **Create a Directory for Your Terraform Files**:
   ```bash
   mkdir terraform-eks-cluster
   cd terraform-eks-cluster
   ```

2. **Create `main.tf`**:
   This file will contain the main configuration for your EKS cluster.
   ```hcl
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
       Terraform = "true"
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


     node_groups = {
       eks_nodes = {
        min_size       = 1
        max_size       = 3
        desired_capacity = 1
        instance_type = "t3.medium"

       }
     }

     tags = {
       Terraform = "true"
       Environment = "dev"
     }
   }
   ```

3. **Create `outputs.tf`**:
   This file will output important information about your EKS cluster.
   ```hcl
   output "cluster_id" {
     description = "The ID of the EKS cluster."
     value       = module.eks.cluster_id
   }

   output "cluster_endpoint" {
     description = "The endpoint of the EKS cluster."
     value       = module.eks.cluster_endpoint
   }

   output "cluster_security_group_id" {
     description = "The security group IDs of the EKS cluster."
     value       = module.eks.cluster_security_group_id
   }
   ```

4. **Create `variables.tf`**:
   This file defines any variables used in your configuration.
   ```hcl
   variable "region" {
     description = "The AWS region to deploy to."
     type        = string
     default     = "us-east-1"
   }
   ```

### Step 2: Initialize Terraform
1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

### Step 3: Create the EKS Cluster
1. **Apply the Terraform Configuration**:
   This step may take several minutes as it provisions the necessary resources on AWS.
   ```bash
   terraform apply
   ```

### Step 4: Configure `kubectl` for EKS
1. **Update kubeconfig**:
   Use the AWS CLI to update your kubeconfig file to use the newly created EKS cluster.
   ```bash
   aws eks --region us-west-2 update-kubeconfig --name my-cluster
   ```

### Step 5: Verify the EKS Cluster
1. **Check Nodes**:
   Verify that your nodes are correctly registered with the EKS cluster.
   ```bash
   kubectl get nodes
   ```

### Troubleshooting Tips
- Ensure your AWS credentials are correctly configured.
- Check the AWS Management Console for any issues with the resources being provisioned.
- Use Terraform commands like `terraform plan` and `terraform apply -refresh=false` for troubleshooting resource dependencies.

### Additional Resources
- [Terraform AWS EKS Module Documentation](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

By following these steps, you should be able to create an EKS cluster on AWS using Terraform effectively.