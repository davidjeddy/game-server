terraform {
  backend "remote" {
    organization = "davidjeddy"

    workspaces {
      name = "game-server"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "game-server"
  region = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}
