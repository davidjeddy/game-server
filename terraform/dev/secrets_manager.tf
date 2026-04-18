resource "aws_secretsmanager_secret" "pa_titans" {
  description             = "Credentials for planetaryannihilation.net used by papatcher.go to update the service version"
  kms_key_id              = aws_kms_key.root.arn
  name                    = join(var.delimiter, ["gs/pa_titans", random_string.pa_titans.id, 0, random_string.root.id])
  recovery_window_in_days = var.delete_timeout

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, ["pa_titans", random_string.pa_titans.id, 0, random_string.root.id]) }
  )
}