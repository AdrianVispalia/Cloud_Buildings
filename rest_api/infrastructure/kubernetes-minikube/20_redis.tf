resource "kubernetes_stateful_set_v1" "cache_ss" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
  }

  spec {
    service_name = "databaseservice"
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "bitnami/redis:latest"
          port {
            container_port = 6379
          }
          env {
            name = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "redis_internal_service" {
  metadata {
    name      = "redis-internal-service"
    namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
  }

  spec {
    selector = {
      app =  kubernetes_stateful_set_v1.cache_ss.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}
