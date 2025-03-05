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

resource "kubernetes_namespace_v1" "rest_api_ns" {
    metadata {
        name = "restapins"
    }
}
