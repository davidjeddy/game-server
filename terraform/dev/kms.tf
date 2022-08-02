
resource "aws_kms_key" "root" {
  description             = "KMS key used for root EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource "aws_kms_alias" "root" {
  name          = "alias/gs/root"
  target_key_id = aws_kms_key.root.key_id
}

resource "aws_kms_key" "satisfactory" {
  description             = "KMS key used for Satisfactory EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource "aws_kms_alias" "satisfactory" {
  name          = "alias/gs/satisfactory"
  target_key_id = aws_kms_key.satisfactory.key_id
}