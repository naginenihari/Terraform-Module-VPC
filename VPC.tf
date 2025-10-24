##VPC Creation
resource "aws_vpc" "main" {
    cidr_block       = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true

    tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
        Name=local.common_name_suffix  
    }

    ) 
}

##Internet Gateway Creation
resource "aws_internet_gateway" "IGW" {            
vpc_id = aws_vpc.main.id

tags = merge(
    var.igw_tags,
    local.common_tags,
    {
        Name=local.common_name_suffix  
    }

    ) 

}

##Public Subnets Creation
resource "aws_subnet" "public" {
count = length(var.public_subnet_cidrs)
vpc_id     = aws_vpc.main.id
cidr_block = var.public_subnet_cidrs[count.index]
availability_zone =local.az_names[count.index]
map_public_ip_on_launch = true

 tags = merge(
        var.public_subnet_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-public-${local.az_names[count.index]}"  ##safey-dev-public-us-east-1a
        }
 )
}
##Privatec Subnets Creation
resource "aws_subnet" "private" {
count = length(var.private_subnet_cidrs)
vpc_id     = aws_vpc.main.id
cidr_block = var.private_subnet_cidrs[count.index]
availability_zone =local.az_names[count.index]

tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name="${local.common_name_suffix}-private-${local.az_names[count.index]}"  ##safey-dev-private-us-east-1a
    }
)
}

##Database Subnets Creation
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone =local.az_names[count.index]
  
 tags = merge(
        var.database_subnet_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-database-${local.az_names[count.index]}"  ##safey-dev-database-us-east-1a
        }
 )
}

##Public Route Table Creation
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

 tags = merge(
        var.public_route_table_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-public"  ##safety
        }
 )
}

##Private Route Table Creation
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

 tags = merge(
        var.private_route_table_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-private"  ##safety
        }
 )
}

##Database Route Table Creation
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

 tags = merge(
        var.database_route_table_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-database"  ##safety
        }
 )
}

##Public Route Table routes are adding
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.IGW.id
}

##Elastic IP Creation
resource "aws_eip" "nat" {
domain   = "vpc"

tags = merge(
        var.eip_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-nat"  ##safety
        }
)


}

##NAT gateway Creation
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

tags = merge(
        var.nat_gateway_tags,
        local.common_tags,
        {
          Name="${local.common_name_suffix}-NATGW"  ##safety
        }
)

# To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

##private Route Table routes are adding--Private egress routes through NAT
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =aws_nat_gateway.nat.id
}

##Database Route Table routes are adding--Private egress routes through NAT
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =aws_nat_gateway.nat.id
}

##Pubilc Route Table Public subnet association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

##Private Route Table Private subnet association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

##Database Route Table database subnet association
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}