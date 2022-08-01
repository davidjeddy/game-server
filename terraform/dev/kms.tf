resource "aws_kms_key" "satisfactory" {
  description             = "KMS key used for Satisfactory EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}