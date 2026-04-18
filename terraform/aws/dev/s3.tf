# bucket to hold the installer bash/shell/etc scripts
module "installers" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = join(var.delimiter, [var.name, var.stage, "installers", random_string.root.id])
  acl    = "private"

  # todo enable bucket object storage tiering
  # intelligent_tiering = {
  #   access_tier = "ARCHIVE_ACCESS"
  #   days        = 30
  # }

  server_side_encryption_configuration = {
    rule = {
      kms_master_key_id = aws_kms_alias.installers.arn
      sse_algorithm     = "aws:kms"
    }
  }

  versioning = {
    enabled = true
  }
}

resource "aws_s3_object" "text_shellscript" {
  for_each = fileset("${path.module}/installers", "*.sh")

  lifecycle {
    prevent_destroy = true
  }

  content_type           = "text/x-shellscript"
  server_side_encryption = "AES256"

  etag   = filemd5("${path.module}/installers/${each.value}")
  source = "${path.module}/installers/${each.value}"
  key    = each.value

  bucket = module.installers.s3_bucket_id
}

resource "aws_s3_object" "title_archives" {
  for_each = fileset("${path.module}/../../../backup", "**/*.*")

  lifecycle {
    prevent_destroy = true
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "2m"
  }

  content_type           = "application/octet-stream"
  server_side_encryption = "AES256"

  etag   = filemd5("${path.module}/../../../backup/${each.value}")
  source = "${path.module}/../../../backup/${each.value}"
  key    = each.value

  bucket = module.installers.s3_bucket_id
}
