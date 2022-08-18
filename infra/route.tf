# Get AWS Public Route Table
data "aws_route_table" "ecs_route" {
  vpc_id = data.aws_vpc.vpc.id
}

# Create Public Route Table Association 1
resource "aws_route_table_association" "esc_route_assoc_1" {
  subnet_id      = aws_subnet.public_ecs_1.id
  route_table_id = data.aws_route_table.ecs_route.id
}

# Create Public Route Table Association 2
resource "aws_route_table_association" "esc_route_assoc_2" {
  subnet_id      = aws_subnet.public_ecs_2.id
  route_table_id = data.aws_route_table.ecs_route.id
}

# Create a Security Group EC2
resource "aws_security_group" "ec2_sg" {
  name        = "tf-ec2-sg"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-ec2-sg"
  }
}
