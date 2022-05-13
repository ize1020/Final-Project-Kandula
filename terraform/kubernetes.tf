# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_service_account" "kandula_sa" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
  depends_on = [module.eks]
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