resource "aws_db_instance" "site_data_store" {
  allocated_storage    = 20
  db_name              = "site_data_store"
  engine               = "postgres"
  engine_version       = "16.3-R2"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "postgres" #needs to be env
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

output "postgres_db" {
  value = aws_db_instance.site_data_store
}
