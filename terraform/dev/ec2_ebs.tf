# -----
# Satisfactory
#-----
resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.this.id
}

#tfsec:ignore:aws-ebs-encryption-customer-key
resource "aws_ebs_volume" "this" {
  availability_zone = module.vpc.azs[0]
  encrypted         = true
  size              = 32

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource "aws_ebs_snapshot" "this" {
  description = aws_ebs_volume.this.id
  volume_id   = aws_ebs_volume.this.id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}
