#########################################
# Terraform configuration for Tender Trap VPC infrastructure
# Defines VPC, subnets, routing, internet gateway, NAT, and EIP resources
#########################################

#########################################
# VPC AND SUBNET CONFIGURATION
#########################################

# Create the main VPC
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

# Create the public subnet
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

# Create the private subnet
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

#########################################
# INTERNET GATEWAY AND PUBLIC ROUTING
#########################################

# Create the Internet Gateway
resource "aws_internet_gateway" "tender_trap_igw" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  tags = merge(
    {
      Name = "tender-trap-igw"
    },
    local.common_tags
  )
}

# Route table for public subnet
resource "aws_route_table" "tender_trap_public_rt" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  # Default route to the Internet
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

#########################################
# PRIVATE ROUTING VIA EC2 NAT INSTANCE
#########################################

# Route table for private subnet
resource "aws_route_table" "tender_trap_private_rt" {
  vpc_id = aws_vpc.tender_trap_vpc.id

  tags = merge(
    {
      Name = "tender-trap-private-rt"
    },
    local.common_tags
  )
}

# Route through NAT EC2 instance's network interface
resource "aws_route" "private_subnet_nat_route" {
  route_table_id         = aws_route_table.tender_trap_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.tender_trap_nat.primary_network_interface_id
}

#########################################
# ROUTE TABLE ASSOCIATIONS
#########################################

# Associate public subnet with its route table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.tender_trap_public.id
  route_table_id = aws_route_table.tender_trap_public_rt.id
}

# Make public route table the main for the VPC
resource "aws_main_route_table_association" "tender_trap_main_rt" {
  vpc_id         = aws_vpc.tender_trap_vpc.id
  route_table_id = aws_route_table.tender_trap_public_rt.id
}

# Associate private subnet with its route table
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.tender_trap_private.id
  route_table_id = aws_route_table.tender_trap_private_rt.id
  depends_on     = [aws_instance.tender_trap_nat]
}

#########################################
# ELASTIC IP ADDRESSES AND ASSOCIATIONS
#########################################

# Allocate EIP for honeypot
resource "aws_eip" "tender_trap_honeypot_eip" {
  domain = "vpc"
}

# Associate honeypot EIP with instance
resource "aws_eip_association" "honeypot_eip_assoc" {
  instance_id   = aws_instance.tender_trap_honeypot.id
  allocation_id = aws_eip.tender_trap_honeypot_eip.id
}

# Allocate EIP for NAT EC2 instance
resource "aws_eip" "tender_trap_nat_eip" {
  domain = "vpc"
}

# Associate NAT EIP with NAT EC2 instance
resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.tender_trap_nat.id
  allocation_id = aws_eip.tender_trap_nat_eip.id
}