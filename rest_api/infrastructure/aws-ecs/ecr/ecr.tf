variable "ecr_repository_name" {
  description = "Repository name for the ECR"
}

variable "aws_region" {
  description = "AWS region"
}

variable "aws_account_id" {
  description = "AWS account ID"
}

resource "aws_ecr_repository" "ecr_repository" {
  name = var.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = false
  }

  force_delete = true
}

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

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

//data "aws_ecr_image" "latest_image" {
//  repository_name = aws_ecr_repository.ecr_repository.name
//  most_recent = true
//}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

//output "latest_ami_id" {
//  value = data.aws_ecr_image.latest_image.image_digest
//}