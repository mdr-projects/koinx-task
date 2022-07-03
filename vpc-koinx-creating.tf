#Creating VPC
#============

resource "aws_vpc" "koinx-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "koinx-vpc"
  }
}

#Creating Subnets
#================

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = "${aws_vpc.koinx-vpc.id}"
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone = "us-west-2a"

  tags = {
    Name = "koinx-publicsubnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = "${aws_vpc.koinx-vpc.id}"
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone = "us-west-2b"

  tags = {
    Name = "koinx-publicsubnet-2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id     = "${aws_vpc.koinx-vpc.id}"
  cidr_block = "10.0.32.0/20"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone = "us-west-2c"

  tags = {
    Name = "koinx-publicsubnet-3"
  }
}


#creating elastice-ip
#====================

resource "aws_eip" "koinx-eip" {
  #instance = "${aws_instance.instance.id}"  
  vpc      = "true"
  tags = {
    Name = "koinx-eip"
  }
}

#creating nat-gateway
#====================

resource "aws_nat_gateway" "koinx-nat" {
  allocation_id = "${aws_eip.koinx-eip.id}"
  subnet_id     = "${aws_subnet.public-subnet-1.id}"

  tags = {
    Name = "koinx-NAT"
  }
}

#creating internet-gateway
#=========================

resource "aws_internet_gateway" "koinx-igw" {
  vpc_id = "${aws_vpc.koinx-vpc.id}"

  tags = {
    Name = "koinx-igw"
  }
}

#creating route-tables
#=====================

resource "aws_route_table" "koinx-rt" {
  vpc_id = "${aws_vpc.koinx-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.koinx-igw.id}"
  }

  tags = {
    Name = "koinx-rt"
  }
}

resource "aws_route_table_association" "koinx-associate-rt" {
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    route_table_id = "${aws_route_table.koinx-rt.id}"
}

resource "aws_route_table_association" "koinx-associate-rt-2" {
    subnet_id = "${aws_subnet.public-subnet-2.id}"
    route_table_id = "${aws_route_table.koinx-rt.id}"
}

resource "aws_route_table_association" "team-associate-rt-3" {
    subnet_id = "${aws_subnet.public-subnet-3.id}"
    route_table_id = "${aws_route_table.koinx-rt.id}"
}
