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
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "game_server"
  region  = var.region

  shared_credentials_files = [
    "$HOME/.aws/credentials"
  ]
}
