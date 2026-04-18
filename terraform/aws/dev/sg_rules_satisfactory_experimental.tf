#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_experimental_0" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory Experimental"
  from_port         = 7778
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 7778
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_experimental_1" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory Experimental"
  from_port         = 15001
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 15001
  type              = "ingress"
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "satisfactory_experimental_2" {
  cidr_blocks       = var.source_cidr
  description       = "Satisfactory Experimental"
  from_port         = 15778
  protocol          = "udp"
  security_group_id = aws_security_group.services.id
  to_port           = 15778
  type              = "ingress"
}
