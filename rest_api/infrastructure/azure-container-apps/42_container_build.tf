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
