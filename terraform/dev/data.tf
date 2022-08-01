data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = false

  filter {
    name = "name"

    values = [
      var.base_ami
    ]
  }

  # Canonical AWS account id
  owners = [
    "099720109477"
  ]
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}
