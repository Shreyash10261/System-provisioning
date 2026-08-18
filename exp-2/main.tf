module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  admin_cidr          = var.admin_cidr
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_pair_name         = var.key_pair_name
  web_count             = var.web_count
  public_subnet_id      = module.network.public_subnet_id
  private_subnet_id     = module.network.private_subnet_id
  web_security_group_id = module.network.web_security_group_id
  db_security_group_id  = module.network.db_security_group_id
}
