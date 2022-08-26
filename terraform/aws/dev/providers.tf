provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

  # This always shows changes to apply
  # https://github.com/hashicorp/terraform-provider-aws/issues/18311
  # default_tags {
  #   tags = var.tags
  # }
}
