terraform {
  // # https://runterrascan.io/ # style linting  for TF files
  // before_hook "terraform fmt" {
  //   commands = ["apply", "init", "plan"]
  //   execute  = ["terraform", "fmt", "-recursive", "."]
  // }

  // # https://terragrunt.gruntwork.io/docs/reference/cli-options/#hclfmt # style linting for HCL files
  // before_hook "terragrunt fmt" {
  //   commands = ["apply", "init", "plan"]
  //   execute  = ["terragrunt", "hclfmt", "."]
  // }

  // # https://runterrascan.io/ # best practice static analysis
  // after_hook "terrascan" {
  //   commands = ["apply", "plan"]
  //   execute  = ["terrascan", "scan", "--config-path", "terrascan_config.toml", "--iac-type", "terraform", "--non-recursive"]
  // }

  // # https://github.com/aquasecurity/tfsec # best practice static analysis
  // after_hook "tfsec" {
  //   commands = ["apply", "plan"]
  //   execute  = ["tfsec", ".", "--concise-output", "--exclude-downloaded-modules", "--tfvars-file", "terraform.tfvars"]
  // }

  // # https://github.com/infracost/infracost # cost control and reporting
  // after_hook "infracost" {
  //   commands = ["apply", "plan"]
  //   execute  = ["infracost", "diff", "--compare-to", "infracost-base.json", "--format", "diff", "--path", ".", "--project-name", "lanordie/dev"]
  // }

  // # https://github.com/terraform-linters/tflint # best practice static analysis
  // after_hook "tflint" {
  //   commands = ["apply", "plan"]
  //   execute  = ["tflint", "--color", "."]
  // }

  // # https://github.com/bridgecrewio/checkov # best practice static analysis
  // after_hook "checkov" {
  //   commands = ["apply", "plan"]
  //   execute  = ["checkov", "--directory", ".", "--framework", "terraform", "--framework", "terraform_plan", "--quiet"]
  // }

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
