provider "aws" {
  region = "us-east-1"
}

# Create key-pair for logging into EC2 in us-east-1 :
resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = file("public-key.pem")
}

# Create VPC in us-east-1 :
resource "aws_vpc" "vpc" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prod-vpc"
  }
}

# Create IGW in us-east-1 :
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "prod-igw"
  }
}

# Get main route table to modify :
data "aws_route_table" "main_route_table" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

# Create route table in us-east-1 :
resource "aws_default_route_table" "internet_route" {
  default_route_table_id = data.aws_route_table.main_route_table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "prod-rt"
  }
}

# Get all available AZ's in VPC for master region :
data "aws_availability_zones" "azs" {
  state = "available"
}

# Create subnet # 1 in us-east-1 :
resource "aws_subnet" "subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.100.10.0/24"
  tags = {
    Name = "prod-sub"
  }
}

# Create Security Group :
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow K8s Cluster Traffic"
  vpc_id      = aws_vpc.vpc.id

# Inbound Rule - Allow SSH :
  ingress {
    description = "allow traffic from MGMT"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["51.89.217.7/32"]
  }

# Inbound Rule - Allow All Traffic from my VPC :
  ingress {
    description = "allow traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16"]
  }

# Outbound Rule - Allow All Traffic :  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-sg"
  }
}