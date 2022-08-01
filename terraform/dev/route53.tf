resource "aws_route53_record" "satisfactory_davidjeddy_com" {
  name    = "satisfactory.davidjeddy.com"
  ttl     = "300"
  type    = "A"
  zone_id = var.route53_zone

  records = [
    aws_eip.this.public_ip
  ]
}

resource "aws_route53_zone" "games_lanordie_com" {
  name = "games.lanordie.com"

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.this.id]) }
  )
}

resource "aws_route53_record" "satisfactory_games_lanordie_com" {
  name    = "satisfactory.games.lanordie.com"
  ttl     = "300"
  type    = "A"
  zone_id = aws_route53_zone.games_lanordie_com.zone_id

  records = [
    aws_eip.this.public_ip
  ]
}