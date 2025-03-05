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
