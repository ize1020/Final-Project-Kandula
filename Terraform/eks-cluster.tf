module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc_module.private_subnets_id

  enable_irsa = true
  
  tags = {
    Environment = "Kandula"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc_module.vpc_id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [
        aws_security_group.k8s_sg.id,
        aws_security_group.consul.id,
        aws_security_group.node_exporter_sg.id
      ]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.large"]

    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}


#Create security group for K8S servers
resource "aws_security_group" "k8s_sg" {
  name = "k8s_sg"
  description = "security group for k8s"
  vpc_id = module.vpc_module.vpc_id
}

resource "aws_security_group_rule" "k8s_ping" {
    from_port   = 8
    to_port     = 0
    protocol = "icmp"
    type= "ingress"
    security_group_id = aws_security_group.k8s_sg.id
#    self = true
    cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
    description = "Allow ping "
}
resource "aws_security_group_rule" "k8s_ssh_access" {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    type= "ingress"
    security_group_id = aws_security_group.k8s_sg.id
#    self = true
    cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
    description = "Allow ssh access in vpc"
}
