resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy = "default"
lifecycle {
    prevent_destroy = true
  }
  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id 

  tags = merge (
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}
#expense-dev-public-us-easat-1
resource "aws_subnet" "public_subnet" {
count = length(var.public_subnet_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.public_subnet_cidrs[count.index]
availability_zone = local.azs[count.index]
map_public_ip_on_launch = true
  tags = merge (
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public-${local.azs[count.index]}"
    }
  )
}

#expense-dev-private-us-east-1
resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  availability_zone = local.azs[count.index]
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge (
    var.common_tags,
    var.private_subnet_tags, 
    {
        Name = "${local.resource_name}-private-${local.azs[count.index]}"
    }
  )
}


resource "aws_subnet" "database_subnet" {
    count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block= var.database_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags =  merge (
    var.common_tags,
    var.database_subnet_tags, 
    {
        Name = "${local.resource_name}- database-${local.azs[count.index]}"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = local.resource_name
    }
  )

    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_tags,
    {
            Name = "${local.resource_name}-public"
    }
  )

  }


resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    var.private_route_tags,

    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database_route" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    var.database_route_tags,
    {
        Name = "${local.resource_name}- database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public_route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.example.id
}

resource "aws_route" "database" {
  route_table_id = aws_route_table.database_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.example.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}


resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database_route.id
}