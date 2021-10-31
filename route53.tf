resource aws_route53_record this {
  zone_id = var.route53_zone

  name    = "satisfactory.davidjeddy.com"
  type    = "A"
  ttl     = "300"
  
  records = [
    aws_eip.this.public_ip
  ]
}