# -----
# Satisfactory
#-----
resource "aws_volume_attachment" "satisfactory" {
  device_name = "/dev/sdf"
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
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource "aws_ebs_snapshot" "satisfactory" {
  description = aws_ebs_volume.satisfactory.id
  volume_id   = aws_ebs_volume.satisfactory.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}
