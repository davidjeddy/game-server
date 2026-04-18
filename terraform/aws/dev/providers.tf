provider "aws" {
  profile = "lanordie_game_server"
  region  = var.region

  shared_credentials_files = [
    "~/.aws/credentials"
  ]

  # This always shows changes to apply
  # https://github.com/hashicorp/terraform-provider-aws/issues/18311
  # default_tags {
  #   tags = var.tags
  # }
}
