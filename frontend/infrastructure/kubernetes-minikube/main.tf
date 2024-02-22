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

resource "kubernetes_namespace_v1" "frontend_ns" {
    metadata {
        name = "frontendns"
    }
}

resource "kubernetes_deployment_v1" "frontend_deploy" {
    metadata {
        name = "frontenddeploy"
        namespace = kubernetes_namespace_v1.frontend_ns.metadata.0.name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "nuxtdev"
            }
        }
        template {
            metadata {
                labels = {
                    app = "nuxtdev"
                }
            }
            spec {
                container {
                    name = "nuxtdev"
                    image = "nuxt_dev"
                    image_pull_policy = "IfNotPresent" # or Never
                    command         = ["yarn"]
                    args            = ["dev"]
                    port {
                        container_port = 3000
                    }
                }
            }
        }
    }
}

resource "kubernetes_service_v1" "frontend_srv" {
    metadata {
        name = "frontendsrv"
        namespace = kubernetes_namespace_v1.frontend_ns.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment_v1.frontend_deploy.spec.0.template.0.metadata.0.labels.app
        }
        port {
            port = 80
            target_port = 3000
        }
        #type = "LoadBalancer"  # Define the service type as LoadBalancer
        type = "NodePort"
    }
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = "frontend-ingress"
    namespace = kubernetes_namespace_v1.frontend_ns.metadata.0.name
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
                name = kubernetes_service_v1.frontend_srv.metadata.0.name
                port {
                    number = kubernetes_service_v1.frontend_srv.spec.0.port.0.port
                }
            }
          }
        }
      }
    }
  }
}

