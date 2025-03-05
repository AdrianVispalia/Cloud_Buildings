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
