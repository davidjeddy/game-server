resource aws_security_group this {
  description = "TCP egress and ingress rules."
  name        = join(var.delimiter, [var.name, var.stage, random_string.this.id])
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = join(var.delimiter, [var.name, var.stage, random_string.this.id])
    }
  )
}
