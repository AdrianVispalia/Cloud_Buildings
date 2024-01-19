variable "region" {
  description = "AWS region"
}

variable "ecs_cluster_name" {
  description = "Name of the cluster for the ECS"
}

variable "ecs_service_name" {
  description = "Service name for the ECS"
}

variable "ecs_task_definition_name" {
  description = "Task definition name for the ECS"
}

variable "ecs_subnet_ids" {
  description = "List of subnet IDs"
}

variable "ecs_security_group_id" {
  description = "Security Group ID for ECS"
}

variable "rds_endpoint_for_ecs" {
  description = "Endpoint for connecting RDS with ECS"
}

variable "ecr_repository_url" {
  description = "URL of the ECR Repository"
}

variable "container_name" {
  type = string
  default = "fastapi-container"
}

variable "ec_endpoint_ip" {
  description = "IP address for connecting ElastiCache with ECS"
}

variable "ec_endpoint_port" {
  description = "Port address for connecting ElastiCache with ECS"
}

variable "vpc_id" {
  description = "My VPC id"
}

variable "internal_subnet_ids" {
  description = "Internal subnet IDs"
}

variable "api_subnet" {
  description = "Subnet public for API"
}

variable "api_lb_sg" {
  description = "Security Group ID for API"
}

variable "elasticache_sg_id" {
  description = "ElastiCache Security group ID"
}

variable "rds_sg_id" {
  description = "RDS Security group ID"
}

resource "aws_lb" "api_lb" {
  name            = "example-lb"
  subnets         = var.api_subnet[*].id
  security_groups = [var.api_lb_sg.id]
}

resource "aws_lb_target_group" "api_lb_tg" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "api_lb_list" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.api_lb_tg.arn
    type             = "forward"
  }
}

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

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.ecs_task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.ecr_repository_url
      network_mode = "awsvpc",
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
      ],
      logConfiguration: {
        logDriver: "awslogs",
        options: {
                    awslogs-create-group: "true",
                    awslogs-group: "awslogs-fastapi-ecs",
                    awslogs-region: var.region,
                    awslogs-stream-prefix: "awslogs-example"
        }
      },
      environment = [
        {
          name  = "JWT_EXPIRATION_MINUTES"
          value = "125"
        },
        {
          name  = "JWT_SECRET"
          value = "secret"
        },
        {
          name  = "JWT_ALGORITHM"
          value = "HS256"
        },
        {
          name  = "DB_ENDPOINT"
          value = var.rds_endpoint_for_ecs
        },
        {
          name  = "DB_NAME"
          value = "test_db"
        },
        {
          name  = "DB_USER"
          value = "postgres"
        },
        {
          name  = "DB_PASSWORD"
          value = "password"
        },
        {
          name  = "REDIS_IP"
          value = tostring(var.ec_endpoint_ip)
        },
        {
          name  = "REDIS_PORT"
          value = tostring(var.ec_endpoint_port)
        },
      ]
    },
  ])
}

resource "aws_security_group" "api_ext_sg" {
  name        = "api_second_sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [var.api_lb_sg.id]
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_cluster" "api_ecs_cluster" {
  name = var.ecs_cluster_name


  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  # capacity_providers = ["FARGATE_SPOT", "FARGATE"]
}

resource "aws_ecs_service" "api_ecs_service" {
  name            = "fastapi-service"
  cluster         = aws_ecs_cluster.api_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.api_ext_sg.id, var.rds_sg_id, var.elasticache_sg_id]
    subnets         = concat(var.api_subnet.*.id, var.internal_subnet_ids.*)
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_lb_tg.id
    container_name   = var.container_name
    container_port   = 80
  }

  depends_on = [aws_lb_listener.api_lb_list]
}

output "load_balancer_ip" {
  value = aws_lb.api_lb.dns_name
}