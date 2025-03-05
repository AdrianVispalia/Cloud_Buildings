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
