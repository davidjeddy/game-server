provider "aws" {
  profile = "lanordie_game_server"
  region  = var.region

  shared_credentials_files = [
    "~/.aws/credentials"
  ]

  # does this stop showing changes all the time?
  # source https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider
  default_tags {
    tags = {
      Owner   = "David J Eddy"
      Contact = "me@davidjeddy.com"
      Version = "0.0.21"
    }

  }
}
