resource "aws_vpc" "tender_trap_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "tender-trap-vpc"
    },
    local.common_tags
  )
}

resource "aws_subnet" "tender_trap_public" {
  vpc_id                  = aws_vpc.tender_trap_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "tender-subnet-public"
    },
    local.common_tags
  )
}

resource "aws_subnet" "tender_trap_private" {
  vpc_id                  = aws_vpc.tender_trap_vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "tender-subnet-private"
    },
    local.common_tags
  )
}

resource "aws_internet_gateway" "tender_trap_igw" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  tags = merge(
    {
      Name = "tender-trap-igw"
    },
    local.common_tags
  )
}

resource "aws_route_table" "tender_trap_public_rt" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tender_trap_igw.id
  }

  tags = merge(
    {
      Name = "tender-trap-public-rt"
    },
    local.common_tags
  )
}

# Associate Public Subnet with the Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.tender_trap_public.id
  route_table_id = aws_route_table.tender_trap_public_rt.id
}

# Make public route table the main route table
resource "aws_main_route_table_association" "tender_trap_main_rt" {
  vpc_id         = aws_vpc.tender_trap_vpc.id
  route_table_id = aws_route_table.tender_trap_public_rt.id
}

# Elastic IP for NAT
resource "aws_eip" "tender_trap_nat_eip" {
  domain = "vpc"

  tags = merge(
    {
      Name = "tender-trap-nat-eip"
    },
    local.common_tags
  )
}

# NAT Gateway (in the public subnet)
resource "aws_nat_gateway" "tender_trap_nat" {
  allocation_id = aws_eip.tender_trap_nat_eip.id
  subnet_id     = aws_subnet.tender_trap_public.id

  tags = merge(
    {
      Name = "tender-trap-nat"
    },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.tender_trap_igw]
}

# Private route table
resource "aws_route_table" "tender_trap_private_rt" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tender_trap_nat.id
  }

  tags = merge(
    {
      Name = "tender-trap-private-rt"
    },
    local.common_tags
  )
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.tender_trap_private.id
  route_table_id = aws_route_table.tender_trap_private_rt.id
}