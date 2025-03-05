output "ec_ip" {
  value = aws_elasticache_cluster.my_elasticache_cluster.cache_nodes[0].address
}

output "ec_port" {
  value = aws_elasticache_cluster.my_elasticache_cluster.cache_nodes[0].port
}
