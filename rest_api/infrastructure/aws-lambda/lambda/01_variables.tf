variable "lambda_subnet_ids" {
  description = "List of subnet IDs"
}

variable "lambda_security_group_id" {
  description = "Security Group ID for Lambda"
}

variable "rds_endpoint_for_lambda" {
  description = "Endpoint for connecting RDS with Lambda"
}

variable "ec_endpoint_ip" {
  description = "IP address for connecting ElastiCache with Lambda"
}

variable "ec_endpoint_port" {
  description = "Port address for connecting ElastiCache with Lambda"
}
