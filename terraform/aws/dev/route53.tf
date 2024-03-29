resource "aws_route53_zone" "lanordie" {
  name = "games.lanordie.com"
}

resource "aws_route53_zone" "games_lanordie_com" {
  name = "games.lanordie.com"

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}

# -----
# KSP
# -----

resource "aws_route53_record" "ksp_games_lanordie_com" {
  name    = "ksp.games.lanordie.com"
  ttl     = "300"
  type    = "A"
  zone_id = aws_route53_zone.games_lanordie_com.zone_id

  records = [
    aws_eip.this.public_ip
  ]
}

# -----
# Planetary Annihilation : Titans
# -----

resource "aws_route53_record" "pa_titans_games_lanordie_com" {
  name    = "pa_titans.games.lanordie.com"
  ttl     = "300"
  type    = "A"
  zone_id = aws_route53_zone.games_lanordie_com.zone_id

  records = [
    aws_eip.this.public_ip
  ]
}

# -----
# Satisfactory
# -----

resource "aws_route53_record" "satisfactory_games_lanordie_com" {
  name    = "satisfactory.games.lanordie.com"
  ttl     = "300"
  type    = "A"
  zone_id = aws_route53_zone.games_lanordie_com.zone_id

  records = [
    aws_eip.this.public_ip
  ]
}
