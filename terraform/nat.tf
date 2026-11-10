# ==============================================================================
# 1. Elastic IP (EIP) for NAT Gateway                                                                                                                                                                                                 
# ==============================================================================
# The NAT Gateway needs a static public IP address to communicate with the internet.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "medigrid-${var.environment}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==============================================================================                                                                                                                                                      
# 2. AWS NAT Gateway (Deployed in the 1st Public Subnet)                                                                                                                                                                              
# ==============================================================================
# Placed in a public subnet so it can route traffic through the Internet Gateway.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "medigrid-${var.environment}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==============================================================================
# 3. Private Route Table
# ==============================================================================
# Routes all outbound traffic (0.0.0.0/0) from Private Subnets to the NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "medigrid-${var.environment}-private-rt"
  }
}

# ==============================================================================
# 4. Associate Private Route Table with all Private Subnets
# ==============================================================================
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
