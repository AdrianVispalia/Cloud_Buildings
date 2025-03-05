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
