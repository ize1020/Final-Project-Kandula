# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_service_account" "opsschool_sa" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "kandula_secret" {
  metadata {
    name = "kandula-credentials"
    namespace = local.k8s_service_account_namespace
  }
  
  data = {
    access_id = base64encode(var.aws_access_key_id)
    secret_access_key = base64encode(var.aws_secret_access_key)
    region = base64encode(var.aws_region)
  }
  # Opaque: arbitary user-defined data
  type = "Opaque"
  depends_on = [module.eks]
}
