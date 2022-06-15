# -----
# Satisfactory
#-----
resource aws_volume_attachment this {
  device_name = "/dev/sdf"
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.this.id
}

resource aws_ebs_volume this {
  availability_zone = join("", [var.region, var.availability_zone])
  encrypted         = true
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}
