data http local_ip {
  url = "http://ipv4.icanhazip.com"
}

data aws_ami ubuntu {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }

  # Canonical AWS account id
  owners = [
    "099720109477"
  ]
}

data template_file user_data {
  template = file("${path.module}/user-data.sh")
}
