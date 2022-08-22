resource "aws_ecs_cluster" "cluster" {
  name = local.ecs.cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family                    = "service"
  requires_compatibilities  = [
    "EC2",
  ]
  network_mode              = "awsvpc"
  cpu                       = 256
  memory                    = 512
  container_definitions     = jsonencode([
    {
      name         = local.container.name
      image        = local.container.image
      essential    = true
      portMappings = local.container.ports
    }
  ])

  volume {
    name      = "task-storage"
    host_path = "/ecs/task-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${aws_subnet.public_subnet_1.availability_zone}, ${aws_subnet.public_subnet_2.availability_zone}]"
  }
}

resource "aws_ecs_service" "service" {
  name                  = local.ecs.service_name
  cluster               = aws_ecs_cluster.cluster.id
  task_definition       = aws_ecs_task_definition.task.arn
  desired_count         = 2
  force_new_deployment  = true

  network_configuration {
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

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  deployment_controller {
    type = "ECS"
  }
}
