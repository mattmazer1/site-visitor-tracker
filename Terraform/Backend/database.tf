resource "aws_db_instance" "site_data_store" {
  allocated_storage    = 10
  db_name              = "site_data_store"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "foobarbaz" #needs to be env
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
