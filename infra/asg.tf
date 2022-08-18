# AWS Auto-scaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "tf-asg"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ecs_conf.name
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  vpc_zone_identifier       = [for s in data.aws_subnet.subnets : s.id]

  timeouts {
    delete = "15m"
  }
}

resource "aws_launch_configuration" "ecs_conf" {
  name_prefix     = "tf-ecs-"
  image_id        = "ami-01711d925a1e4cc3a"
  security_groups = [ aws_security_group.ec2_sg.id ]
  instance_type   = "t2.micro"
  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${aws_ecs_cluster.cluster.name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}
