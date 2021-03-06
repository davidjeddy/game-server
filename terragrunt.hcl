terraform {
  # https://runterrascan.io/
  before_hook "terrascan" {
    commands     = ["apply", "plan"]
    execute      = ["terrascan", "scan", "--iac-type", "terraform", "--non-recursive", "--config-path", "terrascan_config.toml" ]
  }

  # https://github.com/aquasecurity/tfsec
  before_hook "tfsec" {
    commands     = ["apply", "plan"]
    execute      = ["tfsec", ".", "--tfvars-file", "terraform.tfvars", "--exclude-downloaded-modules", "--concise-output"]
    
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
