resource "aws_instance" "this" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = module.vpc.azs[0]
  instance_type     = var.instance_type
  key_name          = var.key_name
  monitoring        = true
  subnet_id         = module.vpc.public_subnets[0]
  user_data         = base64encode(data.template_file.user_data.rendered)

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  root_block_device {
    delete_on_termination = false
    encrypted             = true
    volume_size           = 16
  }

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}
