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
