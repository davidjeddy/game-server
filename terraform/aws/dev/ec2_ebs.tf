# Pattern: [game_name]-[version_from_vendor]-[4_character_random_string]-[counter]-[tf_deployment_random_string]

# -----
# Factorio (/home/ubuntu/factorio)
#-----

resource "aws_volume_attachment" "factorio" {
  device_name = "/dev/sdi"
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.factorio.id
}

resource "aws_ebs_volume" "factorio" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  kms_key_id        = aws_kms_key.factorio.arn
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["factorio", "wube", random_string.factorio.id, 0, random_string.root.id]) },
    { Snapshot = true }, # for Data Lifecycle Management policy
  )
}

resource "aws_ebs_snapshot" "factorio" {
  description = aws_ebs_volume.factorio.id
  volume_id   = aws_ebs_volume.factorio.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["factorio", "wube", random_string.factorio.id, 0, random_string.root.id]) }
  )
}


# -----
# Kerbal Space Program (KSP) (/home/ubuntu/ksp)
#-----

resource "aws_volume_attachment" "ksp" {
  device_name = "/dev/sdf"
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
    { Name = join(var.delimiter, ["ksp","squad", random_string.ksp.id, 0, random_string.root.id]) },
    { Snapshot = true }, # for Data Lifecycle Management policy
  )
}

resource "aws_ebs_snapshot" "ksp" {
  description = aws_ebs_volume.ksp.id
  volume_id   = aws_ebs_volume.ksp.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["ksp","squad", random_string.ksp.id, 0, random_string.root.id]) }
  )
}

# -----
# Planetary Annihilation : Titans (/home/ubuntu/pa_titans)
#-----

resource "aws_volume_attachment" "pa_titans" {
  device_name = "/dev/sdg"
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.pa_titans.id
}

resource "aws_ebs_volume" "pa_titans" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  kms_key_id        = aws_kms_key.pa_titans.arn
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["pa_titans", "pa", random_string.pa_titans.id, 0, random_string.root.id]) },
    { Snapshot = true }, # for Data Lifecycle Management policy
  )
}

resource "aws_ebs_snapshot" "pa_titans" {
  description = aws_ebs_volume.pa_titans.id
  volume_id   = aws_ebs_volume.pa_titans.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["pa_titans", "pa", random_string.pa_titans.id, 0, random_string.root.id]) }
  )
}

# -----
# Satisfactory (/home/ubuntu/satisfactory)
#-----

resource "aws_volume_attachment" "satisfactory" {
  device_name = "/dev/sdh"
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
    { Name = join(var.delimiter, ["satisfactory", "coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) },
    { Snapshot = true }, # for Data Lifecycle Management policy
  )
}

resource "aws_ebs_snapshot" "satisfactory" {
  description = aws_ebs_volume.satisfactory.id
  volume_id   = aws_ebs_volume.satisfactory.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["satisfactory", "coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) }
  )
}

# -----
# Satisfactory Experimental (/home/ubuntu/satisfactory_experimental)
#-----

resource "aws_volume_attachment" "satisfactory_experimental" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.satisfactory_experimental.id
}

resource "aws_ebs_volume" "satisfactory_experimental" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  kms_key_id        = aws_kms_key.satisfactory_experimental.arn
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["satisfactory", "experimental","coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) },
    { Snapshot = true }, # for Data Lifecycle Management policy
  )
}

resource "aws_ebs_snapshot" "satisfactory_experimental" {
  description = aws_ebs_volume.satisfactory_experimental.id
  volume_id   = aws_ebs_volume.satisfactory_experimental.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["satisfactory", "experimental", "coffeestainstudios", random_string.satisfactory.id, 0, random_string.root.id]) }
  )
}
