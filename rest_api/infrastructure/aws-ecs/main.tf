provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./network"
  region = var.aws_region
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

module "ecr" {
  source                    = "./ecr"
  ecr_repository_name       = "fastapi-backend-image"
  aws_region                = var.aws_region
  aws_account_id            = var.aws_account_id
}

module "ecs" {
  source                    = "./ecs"
  region                    = var.aws_region
  ecs_cluster_name          = "backend-cluster"
  ecs_service_name          = "fastapi-backend"
  ecs_task_definition_name  = "service"
  ecr_repository_url        = module.ecr.ecr_repository_url
  ecs_subnet_ids            = module.network.subnet_ids
  ecs_security_group_id     = module.network.lambda_sg_id
  rds_endpoint_for_ecs      = module.database.rds_endpoint
  ec_endpoint_ip            = module.elasticache.ec_ip
  ec_endpoint_port          = module.elasticache.ec_port
  vpc_id                    = module.network.vpc_id
  internal_subnet_ids       = module.network.subnet_ids
  api_subnet                = module.network.api_subnet
  api_lb_sg                 = module.network.api_lb_sg
  rds_sg_id                 = module.network.rds_sg_id
  elasticache_sg_id         = module.network.elasticache_sg_id
}
