resource "aws_security_group" "this" {
  description = "TCP egress and ingress rules."
  name        = join(var.delimiter, [var.name, var.stage, random_string.root.id])
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, random_string.root.id])
    }
  )
}
