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
# Factorio (Factorio)
#-----

resource "aws_kms_key" "factorio" {
  description             = "KMS key used for Factorio EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.factorio.id]) }
  )
}

resource "aws_kms_alias" "factorio" {
  name          = "alias/gs/factorio"
  target_key_id = aws_kms_key.factorio.key_id
}

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

#-----
# Planetary Annihilation : Titans (PA:T)
#-----

resource "aws_kms_key" "pa_titans" {
  description             = "KMS key used for Planetary Annihilation : Titans EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.pa_titans.id]) }
  )
}

resource "aws_kms_alias" "pa_titans" {
  name          = "alias/gs/pa_titans"
  target_key_id = aws_kms_key.pa_titans.key_id
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

# -----
# Satisfactory Experimental
#-----

resource "aws_kms_key" "satisfactory_experimental" {
  description             = "KMS key used for Satisfactory Experimental EBS encryption"
  deletion_window_in_days = var.delete_timeout
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

resource "aws_kms_alias" "_experimental" {
  name          = "alias/gs/_experimental"
  target_key_id = aws_kms_key._experimental.key_id
}
