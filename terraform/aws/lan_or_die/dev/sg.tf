resource "aws_security_group" "management" {
  description = "TCP/UDP egress and ingress rules for management usage"
  name        = join(var.delimiter, [var.name, var.stage, "management", random_string.root.id])
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, "management", random_string.root.id])
    }
  )
}

resource "aws_security_group" "services" {
  description = "TCP egress and ingress rules for services"
  name        = join(var.delimiter, [var.name, var.stage, "services", random_string.root.id])
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, "services", random_string.root.id])
    }
  )
}
