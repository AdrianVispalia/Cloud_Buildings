variable "elasticache_sg_id" {
  description = "ID of the security group for ElastiCache"
}

variable "elasticache_subnet_group_name" {
  description = "Name of the elasticache subnet group"
}

resource "aws_elasticache_cluster" "my_elasticache_cluster" {
  cluster_id           = "my-elasticache-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"

  # Optional: Set other configurations, such as subnet group, security group, etc.
  
  subnet_group_name    = var.elasticache_subnet_group_name
  security_group_ids   = [var.elasticache_sg_id]

  tags = {
    Name = "MyElastiCacheCluster"
  }
}

output "ec_ip" {
  value = aws_elasticache_cluster.my_elasticache_cluster.cache_nodes[0].address
}

output "ec_port" {
  value = aws_elasticache_cluster.my_elasticache_cluster.cache_nodes[0].port
}



