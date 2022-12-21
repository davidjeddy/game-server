build {
  provisioner "shell" {
      script = "./provision.sh"
  }
  sources = ["source.amazon-ebs.this"]
}

data "amazon-ami" "this" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent             = true
  owners                  = ["099720109477"]
  profile                 = var.aws_profile
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
}

source "amazon-ebs" "this" {
  ami_description                           = "Game Server AMI for LAN or DIE."
  ami_name                                  = "${var.server_name}-${formatdate("YYYYMMDDhhmmss", timestamp())}-${var.env}"
  associate_public_ip_address               = true
  ebs_optimized                             = true
  force_delete_snapshot                     = true
  instance_type                             = "m5.large"
  profile                                   = var.aws_profile
  region                                    = var.region
  shared_credentials_file                   = var.shared_credentials_file
  shutdown_behavior                         = "terminate"
  source_ami                                = data.amazon-ami.this.id
  ssh_username                              = "ubuntu"
  temporary_security_group_source_public_ip = true

  run_tags = {
    "Name" = "${var.server_name}-${formatdate("YYYYMMDDhhmmss", timestamp())}-${var.env}"
  }
}

# variables

variable "aws_profile" {
  type    = string
  default = "lanordie_game_server"
}

variable "shared_credentials_file" {
  type = string
  default = "~/.aws/credentials"
}

variable "server_name" {
  type    = string
  default = "game-server"
}

variable "env" {
  type    = string
}

variable "region" {
  type    = string
}
