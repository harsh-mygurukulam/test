# resource "aws_vpc" "main" {
 # cidr_block = var.vpc_cidr
#  tags = { Name = "main-vpc" }
#}

#resource "aws_subnet" "public" {
  #count = length(var.public_subnets)
  #vpc_id = aws_vpc.main.id
  #cidr_block = var.public_subnets[count.index]
  #availability_zone = element(["eu-north-1a", "eu-north-1b"], count.index)
  #map_public_ip_on_launch = true
 # tags = { Name = "public-subnet-${count.index + 1}" }
#}

#resource "aws_subnet" "private" {
  #count = length(var.private_subnets)
  #vpc_id = aws_vpc.main.id
  #cidr_block = var.private_subnets[count.index]
  #availability_zone = element(["eu-north-1a", "eu-north-1a"], count.index)
 # tags = { Name = "private-subnet-${count.index + 1}" }
#}

#resource "aws_internet_gateway" "gw" {
  #vpc_id = aws_vpc.main.id
 # tags = { Name = "internet-gateway" }
#}

#resource "aws_eip" "nat" {
 # domain = "vpc"
#}

#resource "aws_nat_gateway" "nat" {
  #allocation_id = aws_eip.nat.id
 # subnet_id     = aws_subnet.public[0].id
#  tags = { Name = "nat-gateway" }
#}

#resource "aws_route_table" "public" {
  #vpc_id = aws_vpc.main.id
  #route {
   # cidr_block = "0.0.0.0/0"
  #  gateway_id = aws_internet_gateway.gw.id
 # }
#}

#resource "aws_route_table_association" "public" {
  #count = length(aws_subnet.public)
  #subnet_id = aws_subnet.public[count.index].id
 # route_table_id = aws_route_table.public.id
#}

#resource "aws_route_table" "private" {
  #vpc_id = aws_vpc.main.id
 # route {
   # cidr_block = "0.0.0.0/0"
  #  nat_gateway_id = aws_nat_gateway.nat.id
 # }
#}

#resource "aws_route_table_association" "private" {
  #count = length(aws_subnet.private)
  #subnet_id = aws_subnet.private[count.index].id
 # route_table_id = aws_route_table.private.id
#}

#output "vpc_id" {
 # value = aws_vpc.main.id
#}

#output "public_subnet_ids" {
 # value = aws_subnet.public[*].id
#}

#output "private_subnet_ids" {
 # value = aws_subnet.private[*].id
#}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "main-vpc" }
}

# ✅ Sirf 2 Public Subnets (alag-alag AZs me)
resource "aws_subnet" "public" {
  count                   = 2  # ❌ Pehle list thi, ab sirf 2 public subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(["eu-north-1a", "eu-north-1b"], count.index)  # ✅ Alag AZs me jaayega
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-${count.index + 1}" }
}

# ✅ Internet Gateway (Public Subnets ke liye)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "internet-gateway" }
}

# ✅ Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# ✅ Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ✅ Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

