resource "aws_cloudwatch_log_group" "log_group" {
  name              = "log-group-${local.ecs.cluster_name}"
  retention_in_days = 30
  tags              = {
    Name = "log-group-${local.ecs.cluster_name}"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = local.ecs.cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "capa_providers" {
  cluster_name = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capa_provider_1.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.capa_provider_1.name
  }
}

resource "aws_ecs_capacity_provider" "capa_provider_1" {
  # Currentry, we cannot delete capacity provider. If you exec 'terraform destroy', you can delete resouce only on tfstate.
  name = "terraform-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
  }

  depends_on = [
    aws_autoscaling_group.asg
  ]
}

resource "aws_ecs_task_definition" "task" {
  family                    = local.ecs.service_name
  requires_compatibilities  = [
    "EC2",
  ]
  execution_role_arn        = aws_iam_role.ecs.arn
  network_mode              = "awsvpc"
  cpu                       = 512   # 0.5 vCPU
  memory                    = 1024  # 1.0 GiB
  container_definitions     = jsonencode([
    {
      name         = local.container.name
      image        = local.container.image
      essential    = true
      portMappings = local.container.ports
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = aws_cloudwatch_log_group.log_group.name,
          awslogs-region        = local.region
          awslogs-stream-prefix = "${local.container.name}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name                  = local.ecs.service_name
  cluster               = aws_ecs_cluster.cluster.id
  task_definition       = aws_ecs_task_definition.task.arn
  desired_count         = 2
  force_new_deployment  = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capa_provider_1.name
    weight = 100
    base = 1
  }

  network_configuration {
    security_groups = [aws_security_group.sg.id]
    subnets = data.aws_subnets.subnets.ids
  }

  dynamic "load_balancer" {
    for_each = local.container.ports
    content {
      target_group_arn = aws_lb_target_group.group.arn
      container_name   = local.container.name
      container_port   = load_balancer.value.containerPort
    }
  }

  deployment_controller {
    type = "ECS"
  }

  depends_on = [
    aws_ecs_cluster.cluster
  ]
}
