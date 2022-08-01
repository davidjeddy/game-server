terraform {
  # https://runterrascan.io/
  before_hook "terraform" {
    commands     = ["init", "plan", ]
    execute      = ["terraform", "fmt", "-recursive", "." ]
  }

  /* # https://runterrascan.io/
  after_hook "terrascan" {
    commands     = ["apply", "plan"]
    execute      = ["terrascan", "scan", "--iac-type", "terraform", "--non-recursive", "--config-path", "terrascan_config.toml" ]
  } */

  # https://github.com/aquasecurity/tfsec
  after_hook "tfsec" {
    commands     = ["plan", "apply"]
    execute      = ["tfsec", ".", "--tfvars-file", "terraform.tfvars", "--exclude-downloaded-modules", "--concise-output"]
  }

  # https://github.com/infracost/infracost
  after_hook "infracost" {
    commands     = ["plan", "apply"]
    execute      = ["infracost", "diff", "--path", ".", "--compare-to", "infracost-base.json"]
  }

  extra_arguments "custom_vars" {

    commands = [
      "apply",
      "import",
      "plan",
      "push",
      "refresh",
    ]
  }
}
