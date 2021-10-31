resource aws_instance this {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = join("", [var.region, var.availability_zone])
  instance_type     = var.instance_type
  key_name          = var.key_name
  user_data         = "${base64encode(data.template_file.user_data.rendered)}"

  root_block_device {
    encrypted = true
    volume_size = 16
  }

  security_groups = [
    aws_security_group.this.name
  ]

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource aws_volume_attachment this {
  device_name = "/dev/sdf1"
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

resource aws_eip this {
  instance = aws_instance.this.id
  vpc      = true
}