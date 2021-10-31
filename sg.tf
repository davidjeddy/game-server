resource aws_security_group this {
  description = "TCP egress and ingress rules."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )

  // SSH inbound from localhost
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "${chomp(data.http.local_ip.body)}/32",
    ]
  }

  // Satisfactory listening port
  ingress {
    from_port   = 7777
    to_port     = 7777
    protocol    = "udp"
    
    cidr_blocks = [
        "0.0.0.0/0"
    ]
  }

  // Satisfactory beacon
  ingress {
    from_port   = 15000
    to_port     = 15000
    protocol    = "udp"
    
    cidr_blocks = [
        "0.0.0.0/0"
    ]
  }

  // Satisfactory client connection
  ingress {
    from_port = 15777
    to_port   = 15777
    protocol  = "udp"
    
    cidr_blocks = [
        "0.0.0.0/0"
    ]
  }

  // allow all outbounad traffic
  egress {
    to_port   = 0
    from_port = 0
    protocol  = -1

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
