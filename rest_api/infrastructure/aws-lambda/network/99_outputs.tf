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
