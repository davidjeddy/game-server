resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  availability_zone    = module.vpc.azs[0]
  ebs_optimized        = true
  iam_instance_profile = aws_iam_instance_profile.game_server.name
  instance_type        = var.instance_type
  key_name             = aws_key_pair.this.key_name
  monitoring           = true
  subnet_id            = module.vpc.public_subnets[0]
  user_data            = base64encode(data.template_file.user_data.rendered)

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.root.arn
    volume_size = 64

    tags = merge(
      var.tags,
      { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
    )
  }

  vpc_security_group_ids = [
    aws_security_group.management.id,
    aws_security_group.services.id,
  ]

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

# https://davidjeddy.com/generate-a-ssh-key-via-terraform-for-ec2/
# Generate a private TLS key using ED25519 encryption with a length of 2048 bits
resource "tls_private_key" "this" {
  algorithm = "ED25519"
  rsa_bits  = 2048
}

# Leverage the TLS private key to generate a SSH public/private key pair
resource "aws_key_pair" "this" {
  key_name   = join(var.delimiter, [var.name, var.stage, random_string.root.id])
  public_key = tls_private_key.this.public_key_openssh

  # when creating, pipe the private key value to the localhost ~/.ssh directory
  provisioner "local-exec" {
    # create a new one, chmod permissions of the new key, add to key chain
    when    = create
    command = "echo '${tls_private_key.this.private_key_openssh}' > ~/.ssh/${self.id}.pem; chmod 0400 ~/.ssh/${self.id}.pem"
  }

  # When this resources is destroyed, delete the associated key from the file system
  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/${self.id}.pem"
  }
}
