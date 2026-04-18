output "game_server_public_ip" {
  description = "Public IP"
  value       = aws_eip.this.public_ip
}

output "satisfactory_davidjeddy_com" {
  description = "FQDN of server"
  value       = aws_route53_record.satisfactory_davidjeddy_com.fqdn
}

output "satisfactory_games_lanordie_com" {
  description = "FQDN of server"
  value       = aws_route53_record.satisfactory_games_lanordie_com.fqdn
}