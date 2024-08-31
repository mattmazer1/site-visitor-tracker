module "networking" {
  source = "./Networking"
}

module "roles" {
  source = "./Roles"
}

module "frontend" {
  source = "./Frontend"

  public_subnet_id      = module.networking.public_subnet.id
  security_group_id     = module.networking.frontend_security_group.id
  instance_profile_name = module.roles.aws_iam_instance_profile_name
}

module "backend" {
  source = "./Backend"

  private_subnet_id           = module.networking.private_subnet.id
  private_db_backup_subnet_id = module.networking.private_db_backup_subnet.id
  security_group_id           = module.networking.server_security_group.id
  database_security_group_id  = module.networking.database_security_group.id
  instance_profile_name       = module.roles.aws_iam_instance_profile_name
}
