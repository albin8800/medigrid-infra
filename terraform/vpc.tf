# ==============================================================================                                                                                                                                                      
# 1. Main Virtual Private Cloud (VPC)                                                                                                                                                                                                 
# ==============================================================================                                                                                                                                                      
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "medigrid-${var.environment}-vpc"
  }
}

# ==============================================================================                                                                                                                                                      
# 2. Internet Gateway (IGW) - The Front Door to the Public Internet                                                                                                                                                                   
# ==============================================================================                                                                                                                                                      
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "medigrid-${var.environment}-igw"
  }
}

# Automatically query available data center zones in the selected region                                                                                                                                                              
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================                                                                                                                                                      
# 3. Public Subnets (High Availability across 2 Availability Zones)                                                                                                                                                                   
# ==============================================================================                                                                                                                                                      
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                                    = "medigrid-${var.environment}-public-subnet-${count.index + 1}"
    Type                                                    = "Public"
    "kubernetes.io/role/elb"                                = "1"
    "kubernetes.io/cluster/medigrid-${var.environment}-eks" = "shared"
  }
}

# ==============================================================================
# 4. Private Subnets (Isolated for PostgreSQL, Redis, and Internal Pods)
# ==============================================================================
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                                    = "medigrid-${var.environment}-private-subnet-${count.index + 1}"
    Type                                                    = "Private"
    "kubernetes.io/role/internal-elb"                       = "1"
    "kubernetes.io/cluster/medigrid-${var.environment}-eks" = "shared"
  }
}

# ==============================================================================
# 5. Public Route Table & Internet Gateway Association
# ==============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Send all non-local internet traffic (0.0.0.0/0) to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "medigrid-${var.environment}-public-rt"
  }
}

# Associate the Public Route Table with all Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
