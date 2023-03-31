resource "aws_secretsmanager_secret" "circulate_openapi_key" {
  name = "/${var.name}-${terraform.workspace}/openapi/api_key"
}

# This secret contains the currently supported API integrations
resource "aws_secretsmanager_secret_version" "circulate_openapi_key_version" {
  secret_id     = aws_secretsmanager_secret.circulate_openapi_key.id
  secret_string = <<EOF
   {
    "OPENAPI_KEY": ""
   }
EOF
}
