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
      "BUCKET_ID"          = module.installers.s3_bucket_id
      "INSTALLER_DIR_PATH" = "/usr/local/lanordie/gameserver"
      "PA_TITAN_CRED_ARN"  = aws_secretsmanager_secret.pa_titans.arn,
      "REGION"             = data.aws_region.current.name
  })
}

data "aws_iam_policy_document" "installer" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Admin"
      ]
    }
  }
}
