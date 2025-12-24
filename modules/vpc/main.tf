resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.dns_host_name
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name        = "${var.vpc_name}-${var.environment}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.vpc_name}-igw-${var.environment}"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name        = "${var.vpc_name}-public-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = var.subnet_types.public
  }
}

# Private Subnets (ALL with NAT access)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  tags = {
    Name        = "${var.vpc_name}-private-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = var.subnet_types.private
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name        = "${var.vpc_name}-public-rt-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = var.domain
  tags = {
    Name        = "${var.vpc_name}-nat-eip-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name        = "${var.vpc_name}-nat-${var.environment}"
    Environment = var.environment
  }
}

# Private Route Table (for ALL private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.cidr_block
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.vpc_name}-private-rt-${var.environment}"
    Environment = var.environment
  }
}

# Associate ALL private subnets with NAT Gateway
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}