include "common" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  # https://github.com/infracost/infracost # cost control and reporting
  after_hook "infracost" {
    commands = ["apply", "plan"]
    execute  = ["infracost", "diff", "--compare-to", "infracost-base.json", "--path", ".", "--project-name", "lan_or_die/dev"]
  }
}
