provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources3"
  location = "North Europe"
}


resource "azurerm_redis_cache" "example_rc" {
  name                     = "exampleredistest44"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  capacity                 = 0
  family                   = "C"
  sku_name                 = "Basic"
  enable_non_ssl_port      = false
  minimum_tls_version      = "1.2"
  redis_configuration {
    maxmemory_policy = "volatile-lru"
  }
}


resource "azurerm_postgresql_flexible_server" "example_ps" {
  name                   = "example-postgres"
  location               = azurerm_resource_group.example_rg.location
  resource_group_name    = azurerm_resource_group.example_rg.name
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  version                = "11"
  administrator_login    = "postgresql"
  administrator_password = "password"
  zone                   = "2"
}

resource "azurerm_postgresql_flexible_server_database" "example_pd" {
  name                = "testdb"
  server_id           = azurerm_postgresql_flexible_server.example_ps.id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id           = azurerm_postgresql_flexible_server.example_ps.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}


// Containers
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

resource "azurerm_container_app_environment" "example_cae" {
  name                       = "Example-Environment3"
  location                   = azurerm_resource_group.example_rg.location
  resource_group_name        = azurerm_resource_group.example_rg.name
}

resource "azurerm_container_app" "example_ca" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example_cae.id
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
    allow_insecure_connections = true
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
            "%s:%s",
            azurerm_postgresql_flexible_server.example_ps.fqdn,
            "5432"
          )
      }
      env {
          name  = "DB_USER"
          value = azurerm_postgresql_flexible_server.example_ps.administrator_login
      }
      env {
          name  = "DB_PASSWORD"
          value = azurerm_postgresql_flexible_server.example_ps.administrator_password
      }
      env {
          name  = "DB_NAME"
          value = azurerm_postgresql_flexible_server_database.example_pd.name
      }
      env {
          name  = "REDIS_IP"
          value = azurerm_redis_cache.example_rc.hostname
      }
      env {
          name  = "REDIS_PORT"
          value = azurerm_redis_cache.example_rc.port
      }
    }
  }

  depends_on = [ null_resource.docker_build_push ]
}

output "redis_hostname" {
  value = azurerm_redis_cache.example_rc.hostname
}

output "is_database_public" {
  value = azurerm_postgresql_flexible_server.example_ps.public_network_access_enabled
}

output "postgres_endpoint" {
  value = format(
            "%s:%s",
            azurerm_postgresql_flexible_server.example_ps.fqdn,
            "5432"
          )
}
