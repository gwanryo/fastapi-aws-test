data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
locals {
  region = var.aws_region
  ami_id = data.aws_ssm_parameter.ecs_ami.value
  ecr_defaults = {
    repository_name = "tf-ecr"
  }
  ecr = merge(local.ecr_defaults, var.ecr_values)

  ecs_defaults = {
    cluster_name = "tf-ecs-cluster"
    service_name = "tf-ecs-service"
  }
  ecs = merge(local.ecs_defaults, var.ecs_values)

  lb_defaults = {
    name     = "tf-alb"
    internal = false
    target_group = {
      name     = "tf-alb-tg"
      port     = 80
      protocol = "HTTP"
    }
  }
  lb = merge(local.lb_defaults, var.lb_values)

  vpc_defaults = {
    id = ""
  }
  vpc             = merge(local.vpc_defaults, var.vpc)
  use_default_vpc = local.vpc.id == ""

  container_defaults = {
    name  = "fastapi-aws-test"
    image = "gwanryo/fastapi-aws-test"
    ports = [
      {
        containerPort = 80
        hostPort = 80
      }
    ]
  }
  container = merge(local.container_defaults, var.container)
}
