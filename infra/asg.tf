# AWS Auto-scaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ecs-conf.name
  vpc_zone_identifier       = [ aws_subnet.public-ecs-1.id ]

  timeouts {
    delete = "15m"
  }
}

resource "aws_launch_configuration" "ecs-conf" {
  name_prefix     = "tf-ecs-"
  image_id        = "ami-01711d925a1e4cc3a"
  security_groups = [ aws_security_group.ec2-sg.id ]
  instance_type   = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
