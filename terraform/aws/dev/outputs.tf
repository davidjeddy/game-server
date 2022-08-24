output "game_server_public_ip" {
  description = "Public IP"
  value       = aws_eip.this.public_ip
}

output "ksp_games_lanordie_com" {
  description = "FQDN of KSP server"
  value       = aws_route53_record.ksp_games_lanordie_com.fqdn
}

output "pa_titans_games_lanordie_com" {
  description = "FQDN of PA:Titans server"
  value       = aws_route53_record.pa_titans_games_lanordie_com.fqdn
}

output "satisfactory_games_lanordie_com" {
  description = "FQDN of Satisfactory server"
  value       = aws_route53_record.satisfactory_games_lanordie_com.fqdn
}
