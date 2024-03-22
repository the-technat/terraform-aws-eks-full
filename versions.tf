terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = "0.1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.3"
    }
  }
}