resource "kubernetes_stateful_set_v1" "database_ss" {
  metadata {
    name = "postgres"
    namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
  }

  spec {
    service_name = "databaseservice"
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-data"
        namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
      }
      spec {
          access_modes = ["ReadWriteMany"]
          resources {
          requests = {
            storage = "5Gi"
          }
        }
      }   
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:latest"
          port {
            container_port = 5432
          }
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
            read_only  = false
          }
          env {
            name = "POSTGRES_DB"
            value = "testdb"
          }
          env {
            name = "POSTGRES_USER"
            value = "user"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres_internal_service" {
  metadata {
    name      = "postgres-internal-service"
    namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
  }

  spec {
    selector = {
      app =  kubernetes_stateful_set_v1.database_ss.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
