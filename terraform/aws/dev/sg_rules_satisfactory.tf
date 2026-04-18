#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_0" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory"
  from_port         = 7777
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 7777
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_1" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory"
  from_port         = 15000
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 15000
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_2" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory"
  from_port         = 15777
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 15777
  type              = "ingress"
}
