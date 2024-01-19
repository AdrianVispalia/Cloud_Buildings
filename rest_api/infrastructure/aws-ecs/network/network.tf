variable "region" {
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr_block" {
  description = "CIDR block for Subnet 1"
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr_block" {
  description = "CIDR block for Subnet 2"
  default     = "10.0.2.0/24"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = { Name = "my_vpc" }
}

resource "aws_subnet" "my_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet1_cidr_block
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = { Name = "my_subnet1" }
}

resource "aws_subnet" "my_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = { Name = "my_subnet2" }
}

resource "aws_elasticache_subnet_group" "my_subnet_group" {
  name       = "my-elasticache-subnet-group"
  subnet_ids = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lambda_sg" }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for the RDS database"
  vpc_id      = aws_vpc.my_vpc.id
  tags = { Name = "rds_sg" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_conn" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4        = "10.0.0.0/8"
  from_port        = 5432
  to_port          = 5432
  ip_protocol      = "tcp"
}


resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security group for ElastiCache"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names
}

resource "aws_subnet" "public_subnet" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, 10 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "my_vpc-public-${local.azs_names[count.index]}" }
}


resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = { Name = "my_vpc_igw" }
}

resource "aws_eip" "public_ip" {
  count      = local.azs_count
  depends_on = [aws_internet_gateway.my_vpc_igw]
  tags       = { Name = "my_vpc-eip-${local.azs_names[count.index]}" }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = { Name = "my_vpc_route_table" }
}

resource "aws_main_route_table_association" "route_vpc_link" {
  vpc_id         = aws_vpc.my_vpc.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_lb_sg" {
  name        = "lb-sg"
  description = "Security group for the API"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "elasticache_sg_id" {
  value = aws_security_group.elasticache_sg.id
}

output "elasticache_subnet_group_name" {
  value = aws_elasticache_subnet_group.my_subnet_group.name
}

output "api_subnet" {
  value = aws_subnet.public_subnet
}

output "api_lb_sg" {
  value = aws_security_group.my_lb_sg
}