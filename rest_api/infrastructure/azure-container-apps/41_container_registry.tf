resource "azurerm_container_registry" "example_cr" {
  name                     = "mynewexampleacr44"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  sku                      = "Basic"
  admin_enabled            = true
}
