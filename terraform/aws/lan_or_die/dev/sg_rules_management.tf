
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  cidr_blocks       = local.source_cidrs
  description       = "Satisfactory egress"
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.management.id
  to_port           = 0
  type              = "egress"
}

#ts:skip=MEDIUM.AC_AWS_0276 Allow inbound from /32 CIDR
resource "aws_security_group_rule" "ssh_inbound" {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.management.id

  cidr_blocks = [
    "${chomp(data.http.local_ip.body)}/32"
  ]
}