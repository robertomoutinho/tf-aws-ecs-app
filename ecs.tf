locals {
  app_image = module.app_version.image_tag
}

#########
## ECS ##
#########

resource "aws_ecs_service" "app" {
  name    = var.name
  cluster = var.ecs_cluster_id
  task_definition = "${data.aws_ecs_task_definition.app.family}:${max(
    aws_ecs_task_definition.app.revision,
    data.aws_ecs_task_definition.app.revision,
  )}"
  desired_count                      = var.ecs_service_desired_count
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"
  enable_ecs_managed_tags            = true
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.sds
    content {
      registry_arn   = service_registries.value.arn
      port           = var.task_network_mode == "awsvpc" ? var.app_port : null
      container_name = "${var.environment}-${var.name}"
      container_port = var.app_port
    }
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [module.app_sg.this_security_group_id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.app_port
    target_group_arn = element(module.alb.target_group_arns, 0)
  }

  tags = local.local_tags
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.58.1"

  container_name  = var.name
  container_image = local.app_image

  container_cpu                = var.ecs_task_cpu
  container_memory             = var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation

  port_mappings = [
    {
      containerPort = var.app_port
      hostPort      = var.app_port
      protocol      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.app.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }

  environment = var.custom_environment_variables
  secrets     = var.custom_environment_secrets

}

resource "aws_ecs_task_definition" "app" {

  family                   = "${var.environment}-${var.name}"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions    = module.container_definition.json_map_encoded_list

  tags = local.local_tags
}

data "aws_ecs_task_definition" "app" {
  task_definition = "${var.environment}-${var.name}"
  depends_on      = [aws_ecs_task_definition.app]
}