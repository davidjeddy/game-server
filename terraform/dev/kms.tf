# -----
# Kerbal Space Program (KSP)
#-----

resource "aws_kms_key" "ksp" {
  description             = "KMS key used for ksp EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

resource "aws_kms_alias" "ksp" {
  name          = "alias/gs/ksp"
  target_key_id = aws_kms_key.ksp.key_id
}

# -----
# Root
#-----

resource "aws_kms_key" "root" {
  description             = "KMS key used for root EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

resource "aws_kms_alias" "root" {
  name          = "alias/gs/root"
  target_key_id = aws_kms_key.root.key_id
}

# -----
# Satisfactory
#-----

resource "aws_kms_key" "satisfactory" {
  description             = "KMS key used for Satisfactory EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

resource "aws_kms_alias" "satisfactory" {
  name          = "alias/gs/satisfactory"
  target_key_id = aws_kms_key.satisfactory.key_id
}
