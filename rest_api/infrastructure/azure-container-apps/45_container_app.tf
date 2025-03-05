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
