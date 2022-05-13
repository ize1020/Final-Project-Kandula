terraform {
  required_version = ">= 0.13.5"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}

variable "consul_version" {
  default = "1.8.5"
}

variable "ubuntu_account_number" {
  description = "Ubuntu formal account"
  default = "099720109477"
}

variable "pem_key_name" {
  description = "name of ssh key to attach to hosts genereted during apply"
  default     = "kandula_10.pem"
}

variable "kubernetes_version" {
  default = 1.21
  description = "kubernetes version"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "kandula-sa"
}
variable "cluster_name" {
  default = "kandula-project"
}
variable "tag_name" {
  default = "isaac-test"
}
variable "ips" {
  default = {
      "0" = "10.0.2.45"
      "1" = "10.0.3.230"
      "2" = "10.0.2.156"
  }
}