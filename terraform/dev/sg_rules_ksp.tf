#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "ksp_0" {
  cidr_blocks       = local.source_cidrs
  description       = "KSP game ingress"
  from_port         = 6702
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  to_port           = 6702
  type              = "ingress"
}
