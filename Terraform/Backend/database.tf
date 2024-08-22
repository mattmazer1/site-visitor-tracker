resource "aws_db_instance" "site_data_store" {
  allocated_storage     = 19
  max_allocated_storage = 21
  db_name               = "site_data_store"
  engine                = "postgres"
  engine_version        = "16.3"
  storage_type          = "gp2"
  instance_class        = "db.t3.micro"
  username              = "postgres"
  password              =  #needs to be credentials in env
  parameter_group_name  = "default.mysql8.0"
  skip_final_snapshot   = true
}

# output "postgres_db" {
#   value = aws_db_instance.site_data_store
# }

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
