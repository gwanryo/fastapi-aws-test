data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
locals {
  region        = var.aws_region
  ami_id        = data.aws_ssm_parameter.ecs_ami.value
  ecr_defaults  = {
    repository_name   = "terraform-ecr-repository"
  }
  ecr           = merge(local.ecr_defaults, var.ecr_values)

  ecs_defaults = {
    cluster_name  = "terraform-ecs-cluster"
    service_name  = "terraform-ecs-service"
  }
  ecs = merge(local.ecs_defaults, var.ecs_values)

  lb_defaults = {
    name      = "terraform-alb"
    internal  = false
    target_group = {
      name      = "terraform-alb-tg"
      port      = 80
      protocol  = "HTTP"
    }
  }
  lb = merge(local.lb_defaults, var.lb_values)

  vpc_defaults = {
    id = ""
  }
  vpc             = merge(local.vpc_defaults, var.vpc)
  use_default_vpc = local.vpc.id == ""

  container_defaults = {
    name  = var.project_name
    image = "gwanryo/${var.project_name}"
    ports = [
      {
        containerPort = 80
        hostPort      = 80
      }
    ]
  }
  container = merge(local.container_defaults, var.container)
}
