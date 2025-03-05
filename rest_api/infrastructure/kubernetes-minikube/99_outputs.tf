output "postgres_internal_service_cluster_ip" {
  value = kubernetes_service_v1.postgres_internal_service.spec.0.cluster_ip
}

output "redis_internal_service_cluster_ip" {
  value = kubernetes_service_v1.redis_internal_service.spec.0.cluster_ip
}
