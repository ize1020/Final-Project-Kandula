data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu-22" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"]
  }
}

data "http" "myip" {
  url ="http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}


locals {
  cluster_name = "itzik-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# get latest ubuntu 18 ami
data "aws_ami" "ami" {
  owners      = ["099720109477"] # canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

