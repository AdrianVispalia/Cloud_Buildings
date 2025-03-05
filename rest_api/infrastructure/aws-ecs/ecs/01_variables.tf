variable "region" {
  description = "AWS region"
}

variable "ecs_cluster_name" {
  description = "Name of the cluster for the ECS"
}

variable "ecs_service_name" {
  description = "Service name for the ECS"
}

variable "ecs_task_definition_name" {
  description = "Task definition name for the ECS"
}

variable "ecs_subnet_ids" {
  description = "List of subnet IDs"
}

variable "ecs_security_group_id" {
  description = "Security Group ID for ECS"
}

variable "rds_endpoint_for_ecs" {
  description = "Endpoint for connecting RDS with ECS"
}

variable "ecr_repository_url" {
  description = "URL of the ECR Repository"
}

variable "container_name" {
  type = string
  default = "fastapi-container"
}

variable "ec_endpoint_ip" {
  description = "IP address for connecting ElastiCache with ECS"
}

variable "ec_endpoint_port" {
  description = "Port address for connecting ElastiCache with ECS"
}

variable "vpc_id" {
  description = "My VPC id"
}

variable "internal_subnet_ids" {
  description = "Internal subnet IDs"
}

variable "api_subnet" {
  description = "Subnet public for API"
}

variable "api_lb_sg" {
  description = "Security Group ID for API"
}

variable "elasticache_sg_id" {
  description = "ElastiCache Security group ID"
}

variable "rds_sg_id" {
  description = "RDS Security group ID"
}
