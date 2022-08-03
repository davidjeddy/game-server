terraform {
  # https://runterrascan.io/
  before_hook "terraform" {
    commands     = ["apply", "init", "plan"]
    execute      = ["terraform", "fmt", "-recursive", "."]
  }

  # https://runterrascan.io/
  after_hook "terrascan" {
    commands     = ["apply", "plan"]
    execute      = ["terrascan", "scan", "--config-path", "terrascan_config.toml", "--iac-type", "terraform", "--non-recursive"]
  }

  # https://github.com/aquasecurity/tfsec
  after_hook "tfsec" {
    commands     = ["apply", "plan"]
    execute      = ["tfsec", ".", "--concise-output", "--exclude-downloaded-modules", "--tfvars-file", "terraform.tfvars"]
  }

  # https://github.com/infracost/infracost
  after_hook "infracost" {
    commands     = ["apply", "plan"]
    execute      = ["infracost", "diff", "--compare-to", "infracost-base.json", "--path", ".", "--project-name", "game-server"]
  }

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "import",
      "init",
      "plan",
      "push",
      "refresh",
    ]
  }
}
