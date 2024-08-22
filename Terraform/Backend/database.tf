resource "aws_db_instance" "site_data_store" {
  allocated_storage     = 19
  max_allocated_storage = 21
  db_name               = "site_data_store"
  engine                = "postgres"
  engine_version        = "16.3"
  storage_type          = "gp2"
  instance_class        = "db.t3.micro"
  username              = "postgres"
  password              = local.DB_PASSWORD
  parameter_group_name  = "default.postgres16"
  skip_final_snapshot   = true
}

# output "postgres_db" {
#   value = aws_db_instance.site_data_store
# }

data "hcp_vault_secrets_app" "psite" {
  app_name = "psite-secrets"
}

locals {
  DB_PASSWORD = data.hcp_vault_secrets_app.psite.secrets["DB_PASSWORD"]
}
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.site_data_store.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.site_data_store.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.site_data_store.username
  sensitive   = true
}
