
resource "kubernetes_deployment_v1" "rest_api_deploy" {
    metadata {
        name = "restapideploy"
        namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
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
                            kubernetes_service_v1.postgres_internal_service.spec.0.cluster_ip
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
                        value = kubernetes_service_v1.redis_internal_service.spec.0.cluster_ip
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

resource "kubernetes_service_v1" "rest_api_srv" {
    metadata {
        name = "restapisrv"
        namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment_v1.rest_api_deploy.spec.0.template.0.metadata.0.labels.app
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
    namespace = kubernetes_namespace_v1.rest_api_ns.metadata.0.name
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
                name = kubernetes_service_v1.rest_api_srv.metadata.0.name
                port {
                    number = kubernetes_service_v1.rest_api_srv.spec.0.port.0.port
                }
            }
          }
        }
      }
    }
  }
}
