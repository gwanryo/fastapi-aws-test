# Get AWS Public Route Table
data "aws_route_table" "ecs-route" {
  vpc_id = data.aws_vpc.vpc.id
}

# Create Public Route Table Association 1
resource "aws_route_table_association" "esc-route-associa-1" {
  subnet_id      = aws_subnet.public-ecs-1.id
  route_table_id = data.aws_route_table.ecs-route.id
}

# Create Public Route Table Association 2
resource "aws_route_table_association" "esc-route-associa-2" {
  subnet_id      = aws_subnet.public-ecs-2.id
  route_table_id = data.aws_route_table.ecs-route.id
}

# Create a Security Group EC2
resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
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
    Name = "ec2-sg"
  }
}
