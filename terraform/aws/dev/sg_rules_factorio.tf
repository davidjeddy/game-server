#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "factorio_0" {
  cidr_blocks       = var.source_cidr
  description       = "Factorio"
  from_port         = 34197
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 34197
  type              = "ingress"
}
