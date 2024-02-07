terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "minikube"
}

resource "kubernetes_namespace" "rest_api_ns" {
    metadata {
        name = "restapins"
    }
}

resource "kubernetes_deployment" "rest_api_deploy" {
    metadata {
        name = "restapideploy"
        namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "fastapi"
            }
        }
        template {
            metadata {
                labels = {
                    app = "fastapi"
                }
            }
            spec {
                container {
                    name = "fastapi"
                    image = "cloud_buildings_fastapi"
                    image_pull_policy = "IfNotPresent" # or Never
                    port {
                        container_port = 80
                    }
                    env {
                        name  = "JWT_SECRET"
                        value = ""
                    }
                    env {
                        name  = "JWT_ALGORITHM"
                        value = "HS256"
                    }
                    env {
                        name  = "JWT_EXPIRATION_MINUTES"
                        value = "125"
                    }
                    env {
                        name  = "DB_ENDPOINT"
                        value = format(
                            "%s:5432",
                            kubernetes_service.postgres_internal_service.spec.0.cluster_ip
                        )
                    }
                    env {
                        name  = "DB_USER"
                        value = "user"
                    }
                    env {
                        name  = "DB_PASSWORD"
                        value = "password"
                    }
                    env {
                        name  = "DB_NAME"
                        value = "testdb"
                    }
                    env {
                        name  = "REDIS_IP"
                        value = kubernetes_service.redis_internal_service.spec.0.cluster_ip
                    }
                    env {
                        name  = "REDIS_PORT"
                        value = "6379"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "rest_api_srv" {
    metadata {
        name = "restapisrv"
        namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment.rest_api_deploy.spec.0.template.0.metadata.0.labels.app
        }
        port {
            port = 80
            target_port = 80
        }
        #type = "LoadBalancer"  # Define the service type as LoadBalancer
        type = "NodePort"
    }
}

resource "kubernetes_ingress_v1" "rest_api_ingress" {
  metadata {
    name      = "restapi-ingress"
    namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
    annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
  }
  spec {
    rule {
      http {
        path {
          path    = "/(.*)"
          backend {
            service {
                name = kubernetes_service.rest_api_srv.metadata.0.name
                port {
                    number = kubernetes_service.rest_api_srv.spec.0.port.0.port
                }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "database_ss" {
  metadata {
    name = "postgres"
    namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
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
        namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
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

resource "kubernetes_service" "postgres_internal_service" {
  metadata {
    name      = "postgres-internal-service"
    namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
  }

  spec {
    selector = {
      app =  kubernetes_stateful_set.database_ss.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_stateful_set" "cache_ss" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
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

resource "kubernetes_service" "redis_internal_service" {
  metadata {
    name      = "redis-internal-service"
    namespace = kubernetes_namespace.rest_api_ns.metadata.0.name
  }

  spec {
    selector = {
      app =  kubernetes_stateful_set.cache_ss.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}

output "postgres_internal_service_cluster_ip" {
  value = kubernetes_service.postgres_internal_service.spec.0.cluster_ip
}

output "redis_internal_service_cluster_ip" {
  value = kubernetes_service.redis_internal_service.spec.0.cluster_ip
}
