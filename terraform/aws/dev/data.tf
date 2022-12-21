data "aws_ami" "this" {
  most_recent = true

  filter {
    name = "name"

    values = [
      join(var.delimiter, [var.name, "*", var.stage])
    ]
  }

  owners = [
    var.aws_acct_id
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
