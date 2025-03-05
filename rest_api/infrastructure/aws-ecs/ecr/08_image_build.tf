resource "null_resource" "docker_build_push" {
  # This resource is used for local-exec provisioner to run Docker commands
  triggers = {
    ecr_repository_url = aws_ecr_repository.ecr_repository.repository_url
  }

  provisioner "local-exec" {
    command = <<EOT
      # Build Docker image
      docker build -t ${aws_ecr_repository.ecr_repository.repository_url}:latest -f ../../Dockerfile ../..

      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

      # Push Docker image to ECR
      docker push ${aws_ecr_repository.ecr_repository.repository_url}:latest
    EOT
  }
}
