module "vpc_module" {
  source                    = "./vpc"
  vpc_cidr_block            = "10.0.0.0/16"
  private_subnets_cidr_list = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets_cidr_list  = ["10.0.5.0/24", "10.0.6.0/24"]
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.6.1"
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = module.vpc_module.private_subnets_id

  enable_irsa = true
  
  tags = {
    Environment = "Kandula"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc_module.vpc_id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      #instance_types         = ["t3.medium"]
      instance_types = ["t3.micro"]
      vpc_security_group_ids = [ aws_security_group.k8s_sg.id ]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      #instance_types = ["t3.medium"]
      instance_types = ["t3.micro"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      #instance_types = ["t3.medium"]
      instance_types = ["t3.micro"]

    }
  }
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.7.0"
  create_role                   = true
  role_name                     = format("%s-k8s-sa-role", var.tag_name)
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

# Assume role for eks 
resource "aws_iam_role" "eks-join" {
  name               = "eks-join"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

}

# Create the instance profile
resource "aws_iam_instance_profile" "eks-join" {
  name = "eks-join"
  role = aws_iam_role.eks-join.name
}
