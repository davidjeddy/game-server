# bucket to hold the installer bash/shell/etc scripts
module "installers" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = join(var.delimiter, [var.name, var.stage, "installers", random_string.root.id])
  acl    = "private"

  server_side_encryption_configuration = {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.installers.arn
      sse_algorithm     = "aws:kms"
    }
  }

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "text_shellscript" {
  for_each = fileset("${path.module}/installers", "*.sh")

  content_type           = "text/x-shellscript"
  server_side_encryption = "AES256"

  etag   = filemd5("${path.module}/${each.value}")
  source = "${path.module}/${each.value}"
  key    = each.value

  bucket = module.s3_installers.s3_bucket
}