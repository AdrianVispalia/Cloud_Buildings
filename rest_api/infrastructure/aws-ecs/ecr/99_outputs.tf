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
