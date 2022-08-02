# Pattern: [game_name]-[version_from_vendor]-[4_character_random_string]-[counter]-[tf_deployment_random_string]

# -----
# Kerbal Space Program (KSP)
#-----

resource "aws_volume_attachment" "ksp" {
  device_name = "/dev/sdf" # will be /dev/nvme0n1 on the instance
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.ksp.id
}

resource "aws_ebs_volume" "ksp" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  kms_key_id        = aws_kms_key.ksp.arn
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["ksp", "1.x", "squad", random_string.ksp.id, 0, random_string.root.id]) }
  )
}

resource "aws_ebs_snapshot" "ksp" {
  description = aws_ebs_volume.ksp.id
  volume_id   = aws_ebs_volume.ksp.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["ksp", "1.x", "squad", random_string.ksp.id, 0, random_string.root.id]) }
  )
}

# -----
# Satisfactory
#-----

resource "aws_volume_attachment" "satisfactory" {
  device_name = "/dev/sdg" # will be /dev/nvme1n1 on the instance
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.satisfactory.id
}

resource "aws_ebs_volume" "satisfactory" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  kms_key_id        = aws_kms_key.satisfactory.arn
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["satisfactory", "update5", "coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) }
  )
}

resource "aws_ebs_snapshot" "satisfactory" {
  description = aws_ebs_volume.satisfactory.id
  volume_id   = aws_ebs_volume.satisfactory.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["satisfactory", "update5", "coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) }
  )
}
