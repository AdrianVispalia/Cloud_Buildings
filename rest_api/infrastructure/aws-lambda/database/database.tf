variable "rds_vpc_id" {
  description = "ID of the VPC the RDS will reside in"
}

variable "rds_subnet_ids" {
  description = "List of subnet IDs"
}

variable "rds_sg_id" {
  description = "ID of the security group for RDS"
}

resource "aws_db_instance" "my_db_instance" {
  identifier            = "my-db-instance"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "15.4"
  instance_class        = "db.t3.micro"
  db_name               = "test_db"
  username              = "postgres"
  password              = "password"
  port                  = 5432
  publicly_accessible   = false
  skip_final_snapshot   = true
  multi_az              = false
  storage_encrypted     = false
  apply_immediately     = true
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name  = aws_db_subnet_group.my_db_subnet_group.name
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.rds_subnet_ids
}

output "rds_endpoint" {
  value = aws_db_instance.my_db_instance.endpoint
}
