locals {
  source_cidrs = [
    "0.0.0.0/0"
  ]
}

resource aws_security_group_rule egress {
  cidr_blocks       = local.source_cidrs
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"
}

resource aws_security_group_rule satisfacotry_0 {
  cidr_blocks       = local.source_cidrs
  from_port         = 7777
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 7777
  type              = "ingress"
}

resource aws_security_group_rule satisfacotry_1 {
  cidr_blocks       = local.source_cidrs
  from_port         = 15000
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 15000
  type              = "ingress"
}

resource aws_security_group_rule satisfacotry_2 {
  cidr_blocks       = local.source_cidrs
  from_port         = 15777
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 15777
  type              = "ingress"
}

# Special ingress ports
resource aws_security_group_rule ssh_inbound {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id

  cidr_blocks = [
    "${chomp(data.http.local_ip.body)}/32"
  ]
}