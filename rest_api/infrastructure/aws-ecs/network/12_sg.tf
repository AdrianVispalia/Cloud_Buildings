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
