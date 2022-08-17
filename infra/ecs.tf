resource "aws_ecs_cluster" "cluster" {
  name               = local.ecs["cluster_name"]
}

resource "aws_ecs_task_definition" "task" {
  family = "service"
  requires_compatibilities = [
    "EC2",
  ]
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([
    {
      name      = local.container.name
      image     = local.container.image
      essential = true
      portMappings = [
        for port in local.container.ports :
        {
          containerPort = port
          hostPort      = port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = local.ecs.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets          = [for s in data.aws_subnet.subnets : s.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.group.arn
    container_name   = local.container.name
    container_port   = 80
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  deployment_controller {
    type = "ECS"
  }
}
