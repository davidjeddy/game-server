# Hashicorp Providers
resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "satisfactory" {
  length  = 4
  special = false
  upper   = false
}
