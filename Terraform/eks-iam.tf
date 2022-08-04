module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.7.0"
  create_role                   = true
  role_name                     = "k8s-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_role" "eks" {
  name               = "eks"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
}

resource "aws_iam_policy" "eks" {
  name        = "eks"
  description = "Allows nodes full accesses to eks."
  policy      = file("${path.module}/policies/eks.json")
}

resource "aws_iam_policy_attachment" "eks" {
  name       = "eks"
  roles      = [aws_iam_role.eks.name]
  policy_arn = aws_iam_policy.eks.arn
}

resource "aws_iam_instance_profile" "eks" {
  name  = "eks"
  role = aws_iam_role.eks.name
}