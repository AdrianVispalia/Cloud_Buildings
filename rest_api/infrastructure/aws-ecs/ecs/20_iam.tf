resource "aws_iam_role" "ecs_execution_role" {
  name = "ECS_Execution_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}



resource "aws_iam_policy" "iam_policy_ecs" { 
  name        = "aws_iam_policy_for_terraform_aws_ecs_role"
  path        = "/"
  description = "AWS IAM Policy for ECS getting ECR auth"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.iam_policy_ecs.arn
}
