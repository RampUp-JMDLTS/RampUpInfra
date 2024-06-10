# -----------------------
# NETWORK 
# -----------------------
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "epam_vpc"
  }
}

resource "aws_subnet" "public_subnets" {

  for_each = { for s in var.public_subnets : s.name => s }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_range
  availability_zone = each.value.zone

  tags = {
    Name = "epam_public_subnet_${each.value.name}"
  }
}

resource "aws_subnet" "private_subnets" {

  for_each = { for s in var.private_subnets : s.name => s }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_range
  availability_zone = each.value.zone

  tags = {
    Name = "epam_private_subnet_${each.value.name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "epam_igw"
  }
}

resource "aws_route_table" "vpc_public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "epam_public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_associations" {
  for_each = { for s in var.public_subnets : s.name => s }

  subnet_id      = aws_subnet.public_subnets["${each.key}"].id
  route_table_id = aws_route_table.vpc_public_route_table.id
}


resource "aws_route_table" "vpc_private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "epam_private_route_table"
  }
}

resource "aws_route_table_association" "private_subnet_associations" {
  for_each = { for s in var.private_subnets : s.name => s }

  subnet_id      = aws_subnet.private_subnets["${each.key}"].id
  route_table_id = aws_route_table.vpc_private_route_table.id
}