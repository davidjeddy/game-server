#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "pa_titans_0" {
  cidr_blocks       = local.source_cidrs
  description       = "Planetary Annihilation : Titans"
  from_port         = 20545
  protocol          = "tcp"
  security_group_id = aws_security_group.services.id
  to_port           = 20545
  type              = "ingress"
}
