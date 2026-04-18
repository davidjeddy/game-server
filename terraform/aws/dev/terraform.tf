terraform {
  backend "remote" {
    organization = "eddy_enterprises"

    workspaces {
      name = "lanordie"
    }
  }

  required_version = ">= 1.2.6"
}
