#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "ksp_0" {
  cidr_blocks       = var.source_cidr
  description       = "Kerbal Space Program"
  from_port         = 6702
  protocol          = "tcp"
  security_group_id = aws_security_group.services.id
  to_port           = 6702
  type              = "ingress"
}
