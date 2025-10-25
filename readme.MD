# Terraform AWS VPC

This module creates the following resources.
* VPC
* IGW
* 2 Public subnets in us-east-1a and us-east-1b AZ
* 2 Private subnets in us-east-1a and us-east-1b AZ
* 2 Database subnets in us-east-1a and us-east-1b AZ
* Public Route table
* Private Route table
* Database Route table
* EIP for NAT
* NAT Gateway in public subnet 1a az
* IGW route is added to public route table
* NAT gateway route to private and database route tables
* Route table association with subnets
* VPC to default VPC peering
* Public route table to default VPC route
* Default VPC main route table to created VPC route

### Inputs

* vpc_cidr - (Required). User must supply the CIDR for VPC.
* project_name - (Required). User must supply the project name
* Environment - (Required). User must supply the environment name
* vpc_tags-(optional). user can supply the tags attach to the VPC
* IGW-(Required). user must check the code IGW created or not
* igw_tags-(optional). user can supply the tags attach to the IGW
* public_subnet_cidrs(Required). User must supply the CIDR for public subnets.
* private_subnet_cidrs(Required). User must supply the CIDR for private subnets.
* database_subnet_cidrs(Required). User must supply the CIDR for database subnets.
* public_subnet_tags-(optional). user can supply the tags attached to public subnets
* private_subnet_tags-(optional). user can supply the tags attach to private subnets
* datebase_subnet_tags-(optional). user can supply the tags attach to database subnets
* public_route_table_tags-(optional). user can supply the tags attached to public routetable
* private_route_table_tags-(optional). user can supply the tags attach to private routetable
* datebase_route_table_tags-(optional). user can supply the tags attach to database routetable
* EIP-(Required) user can supply the EIP request
* eip_tags(optional) user can supply the tags attach to EIP
* NAT GW: (Required) user can create the NAT Gw for private subnet tables routing
* nat_gateway_tags(optional)-user can supply the tags attach to NAT GW
* peering_required(Optional)-user can supply the true or false for peering connection
* peering_tags(optional)-user can supply the tags attach to peering connection

### Outputs

* vpc_id - VPC ID will created
* Public_subnets - Public subnets will created and get the ID's of  public subnets
* Private_subnets - private subnets will created and get the ID's of  private subnets
* database_subnets - database subnets will created and get the ID's of  database subnets