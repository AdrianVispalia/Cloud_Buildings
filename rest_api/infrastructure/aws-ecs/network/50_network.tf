data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = { Name = "my_vpc_igw" }
}

resource "aws_eip" "public_ip" {
  count      = local.azs_count
  depends_on = [aws_internet_gateway.my_vpc_igw]
  tags       = { Name = "my_vpc-eip-${local.azs_names[count.index]}" }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = { Name = "my_vpc_route_table" }
}

resource "aws_main_route_table_association" "route_vpc_link" {
  vpc_id         = aws_vpc.my_vpc.id
  route_table_id = aws_route_table.my_route_table.id
}
