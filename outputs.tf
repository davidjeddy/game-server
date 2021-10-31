output public_ip {
    description = "Public IP"
    value = aws_eip.this.public_ip
}

output fqdn {
    description = "FQDN of server"
    value = aws_route53_record.this.fqdn
}