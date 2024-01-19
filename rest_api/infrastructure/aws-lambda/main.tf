provider "aws" {
  region = "eu-north-1"
}

module "network" {
  source = "./network"
}

module "database" {
  source         = "./database"
  rds_vpc_id     = module.network.vpc_id
  rds_subnet_ids = module.network.subnet_ids
  rds_sg_id      = module.network.rds_sg_id
}

module "elasticache" {
  source                        = "./elasticache"
  elasticache_sg_id             = module.network.elasticache_sg_id
  elasticache_subnet_group_name = module.network.elasticache_subnet_group_name
}

module "lambda" {
  source                    = "./lambda"
  lambda_subnet_ids         = module.network.subnet_ids
  lambda_security_group_id  = module.network.lambda_sg_id
  rds_endpoint_for_lambda   = module.database.rds_endpoint
  ec_endpoint_ip            = module.elasticache.ec_ip
  ec_endpoint_port          = module.elasticache.ec_port
}
