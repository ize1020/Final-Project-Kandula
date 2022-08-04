terraform {
  required_version = ">= 1.2"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}
