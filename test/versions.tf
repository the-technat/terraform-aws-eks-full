terraform {
  backend "remote" {
    organization = "technat"

    workspaces {
      name = "kubernetes-demo"
    }
  }
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    bcrypt = {
      source = "viktorradnai/bcrypt"
    }
    random = {
      source = "hashicorp/random"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
  }
}