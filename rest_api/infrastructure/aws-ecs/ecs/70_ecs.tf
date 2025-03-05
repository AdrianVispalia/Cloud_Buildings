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
