terraform {
  backend "remote" {
    organization = "eddy_enterprises"

    workspaces {
      name = "lanordie"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.6"
}
