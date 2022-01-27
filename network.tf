resource "aws_vpc" "remotedev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "remotedev_vpc"
  }
}

resource "aws_subnet" "remotedev_subnet_a" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.remotedev_vpc.id
  availability_zone       = var.aws_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "remotedev-subnet-a"
  }
}

resource "aws_internet_gateway" "remotedev_igw" {
  vpc_id = aws_vpc.remotedev_vpc.id

  tags = {
    Name = "remotedev-igw"
  }
}

resource "aws_route_table" "remotedev_route_table" {
  vpc_id = aws_vpc.remotedev_vpc.id

  tags = {
    Name = "remotedev-route-table"
  }
}

resource "aws_route" "remotedev_route" {
  route_table_id         = aws_route_table.remotedev_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.remotedev_igw.id
}

resource "aws_route_table_association" "remotedev_route_table_a" {
  route_table_id = aws_route_table.remotedev_route_table.id
  subnet_id      = aws_subnet.remotedev_subnet_a.id
}

