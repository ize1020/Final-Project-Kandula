output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc_module.vpc_id
}

output "private_subnets_id" {
  value = module.vpc_module.private_subnets_id
}

output "public_subnets_id" {
  value = module.vpc_module.public_subnets_id
}

output "vpc_cidr" {
  value = module.vpc_module.vpc_cidr
}
output "Bastion-ansible_public_addresses" {
    value = aws_instance.Bastion-ansible[0].public_ip
}
output "consul_servers_1" {
  value = aws_instance.consul-Server[2].private_ip
}
output "consul_servers_2" {
  value = aws_instance.consul-Server[1].private_ip
}
output "consul_servers_3" {
  value = aws_instance.consul-Server[0].private_ip
}
output "consul_agent_ips" {
  value = aws_instance.consul-agent[*].private_ip
}

#output for k8s cluster

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.iam_assumable_role_admin.iam_role_arn
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = module.iam_assumable_role_admin.iam_role_name
}