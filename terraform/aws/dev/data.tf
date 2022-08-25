data "aws_ami" "ubuntu" {
  most_recent = false

  filter {
    name = "name"

    values = [
      var.base_ami
    ]
  }

  # Canonical AWS account id
  owners = [
    "099720109477"
  ]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "template_file" "user_data" {
  template = templatefile(
    "${path.module}/user-data.sh",
    {
      "PA_TITAN_CRED_ARN" = aws_secretsmanager_secret.pa_titans.arn,
      "REGION"            = data.aws_region.current.name
  })
}
