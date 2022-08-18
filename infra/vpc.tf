data "aws_vpc" "vpc" {
  id      = local.use_default_vpc ? null : local.vpc["id"]
  default = local.use_default_vpc
}

# Create a Public Subnet 1
resource "aws_subnet" "public_ecs_1" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "172.31.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-ecs-1"
  }
}

# Create a Public Subnet 2
resource "aws_subnet" "public_ecs_2" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "172.31.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-ecs-2"
  }
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.vpc.id ]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.subnets.ids)
  vpc_id   = data.aws_vpc.vpc.id
  id       = each.value
  # availability_zone = each.value
}
