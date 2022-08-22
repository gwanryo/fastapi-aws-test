resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-${local.container.name}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  depends_on = [
    aws_vpc.vpc
  ]

  tags = {
    Name = "terraform-public-subnet-${local.container.name}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  depends_on = [
    aws_vpc.vpc
  ]

  tags = {
    Name = "terraform-public-subnet-${local.container.name}"
  }
}

data "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_route_table_association" "route_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = data.aws_route_table.route.id

  depends_on = [
    data.aws_route_table.route
  ]
}

resource "aws_route_table_association" "route_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = data.aws_route_table.route.id

  depends_on = [
    data.aws_route_table.route
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc
  ]

  tags = {
    Name = "terraform-internet-gateway-${local.container.name}"
  }
}

resource "aws_security_group" "sg" {
  name        = "terraform-security-group-${local.container.name}"
  vpc_id      = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
  }

    ingress {
        from_port       = 443
        to_port         = 443
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
    Name = "terraform-security-group-${local.container.name}"
  }
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [ aws_vpc.vpc.id ]
  }

  depends_on = [
    aws_vpc.vpc
  ]
}
