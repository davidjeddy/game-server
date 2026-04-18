include "common" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  common = find_in_parent_folders("common.yml")
}

