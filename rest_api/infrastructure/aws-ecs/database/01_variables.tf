variable "rds_vpc_id" {
  description = "ID of the VPC the RDS will reside in"
}

variable "rds_subnet_ids" {
  description = "List of subnet IDs"
}

variable "rds_sg_id" {
  description = "ID of the security group for RDS"
}
