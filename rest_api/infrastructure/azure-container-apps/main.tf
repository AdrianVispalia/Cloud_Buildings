provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources3"
  location = "West Europe"
}


resource "azurerm_container_registry" "example_cr" {
  name                     = "mynewexampleacr44"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "null_resource" "docker_build_push" {

  provisioner "local-exec" {
    command = <<EOT
      # Build Docker image
      docker build -t rest_api:latest -f ../../Dockerfile ../..

      echo "Before auth"
      # Authenticate Docker to ECR
      az acr login --name ${azurerm_container_registry.example_cr.name}

      echo "Before tag"
      docker tag rest_api:latest ${azurerm_container_registry.example_cr.name}.azurecr.io/rest_api:latest

      echo "Before push"
      # Push Docker image to ECR
      docker push ${azurerm_container_registry.example_cr.name}.azurecr.io/rest_api:latest
    EOT
  }

  depends_on = [ azurerm_container_registry.example_cr ]
}

resource "azurerm_container_app_environment" "example_cap" {
  name                       = "Example-Environment3"
  location                   = azurerm_resource_group.example_rg.location
  resource_group_name        = azurerm_resource_group.example_rg.name
}

resource "azurerm_container_app" "example_ca" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example_cap.id
  resource_group_name          = azurerm_resource_group.example_rg.name
  revision_mode                = "Single"

  secret {
    name  = "password"
    value = azurerm_container_registry.example_cr.admin_password
  }

  registry {
    server = azurerm_container_registry.example_cr.login_server
    username = azurerm_container_registry.example_cr.admin_username
    password_secret_name = "password"
  }

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled = true
    target_port = 80
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "restapicontainer"
      image  = "${azurerm_container_registry.example_cr.name}.azurecr.io/rest_api:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "JWT_SECRET"
        value = ""
      }
      env {
          name  = "JWT_ALGORITH"
          value = "HS256"
      }
      env {
          name  = "JWT_EXPIRATION_MINUTES"
          value = "125"
      }
      env {
          name  = "DB_ENDPOINT"
          value = "postgres:5432"
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
          value = "test_deb"
      }
      env {
          name  = "REDIS_IP"
          value = "redis"
      }
      env {
          name  = "REDIS_PORT"
          value = "6379"
      }
    }
  }

  depends_on = [ null_resource.docker_build_push ]
}
