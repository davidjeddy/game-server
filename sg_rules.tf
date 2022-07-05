locals {
  source_cidrs = [
    "0.0.0.0/0"
  ]
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource aws_security_group_rule egress {
  cidr_blocks       = local.source_cidrs
  description       = "Satisfactory egress"
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource aws_security_group_rule satisfactory_0 {
  cidr_blocks       = local.source_cidrs
  description       = "Satisfactory ingress"
  from_port         = 7777
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 7777
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource aws_security_group_rule satisfactory_1 {
  cidr_blocks       = local.source_cidrs
  description       = "Satisfactory ingress"
  from_port         = 15000
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 15000
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource aws_security_group_rule satisfactory_2 {
  cidr_blocks       = local.source_cidrs
  description       = "Satisfactory ingress"
  from_port         = 15777
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 15777
  type              = "ingress"
}

#ts:skip=MEDIUM.AC_AWS_0276 Allow inbound from /32 CIDR
resource aws_security_group_rule ssh_inbound {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id

  cidr_blocks = [
    "${chomp(data.http.local_ip.body)}/32"
  ]
}