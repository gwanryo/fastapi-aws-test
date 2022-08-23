# AWS Auto-scaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "terraform-autoscaling-group-${local.container.name}"
  max_size                  = 6
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ecs_conf.name
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  vpc_zone_identifier       = data.aws_subnets.subnets.ids

  depends_on = [
    data.aws_subnets.subnets
  ]

  timeouts {
    delete = "15m"
  }
}

resource "aws_launch_configuration" "ecs_conf" {
  name_prefix     = "terraform-ecs-"
  image_id        = local.ami_id
  security_groups = [ aws_security_group.sg.id ]
  instance_type   = "t2.micro"
  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${local.ecs.cluster_name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}
