terraform{
    required_providers{
        aws={
            source="hashicorp/aws"
            version="~>4.48.0"
        }
    }
    backend "s3"{
        bucket="dtc-tf-states"
        key= "state"
        workspace_key_prefix ="dtc"
        region = "us-east-1"
        access_key=""
        secret_key=""
    }
}

provider "aws"{
    region="us-east-1"
    access_key=""
    secret_key=""
}

resource "aws_vpc" "dtc_vpc"{

    cidr_block=var.vpc_cidr
    enable_dns_hostnames=true
    tags={
        Name = "dtc_vpc"
    }
}

resource "aws_subnet" "dtc_public_subnet"{
    count = length(var.zone)
    depends_on = [aws_vpc.dtc_vpc]
    availability_zone = element(var.zone,count.index)
    vpc_id=aws_vpc.dtc_vpc.id
    cidr_block=element(var.pub_cidr,count.index)
    map_public_ip_on_launch= true
    tags = {
        Name ="dtc_public_subnet ${count.index+1}"
    }
}

resource "aws_subnet" "dtc_private_subnet"{
    count= length(var.priv_cidr)
    depends_on = [aws_vpc.dtc_vpc]
    availability_zone = element(var.zone,count.index)
    vpc_id=aws_vpc.dtc_vpc.id
    cidr_block= element(var.priv_cidr,count.index)
    map_public_ip_on_launch= true
    tags = {
        Name ="dtc_private_subnet ${count.index+1}"
    }
}

resource "aws_internet_gateway" "dtc_gateway"{
    depends_on=[aws_vpc.dtc_vpc,aws_subnet.dtc_public_subnet,aws_subnet.dtc_private_subnet]
    vpc_id= aws_vpc.dtc_vpc.id
    tags= {
        name ="DTC IGW"
    }
}

resource "aws_eip" "nat_ip"{
    vpc=true
}

resource "aws_nat_gateway""nat_gw"{
    depends_on=[aws_internet_gateway.dtc_gateway]
    subnet_id = element(aws_subnet.dtc_public_subnet.*.id,0)
    allocation_id = aws_eip.nat_ip.id
    tags={
        Name="NAT Gateway"
    }
}

resource "aws_route_table" "dtc_public_routes"{
    vpc_id = aws_vpc.dtc_vpc.id
    route{
        cidr_block ="0.0.0.0/0"
        gateway_id=aws_internet_gateway.dtc_gateway.id
    }
    tags={
        Name="public routes"
    }
}

resource "aws_route_table_association" "pub"{
    count = length(aws_subnet.dtc_public_subnet)
    route_table_id = aws_route_table.dtc_public_routes.id
    subnet_id= aws_subnet.dtc_public_subnet[count.index].id
}


resource "aws_route_table" "dtc_private_routes"{
    vpc_id = aws_vpc.dtc_vpc.id
    route{
        cidr_block ="0.0.0.0/0"
        gateway_id=aws_nat_gateway.nat_gw.id
    }
    tags={
        Name="private routes"
    }
}

resource "aws_route_table_association" "private"{
    count = length(aws_subnet.dtc_private_subnet)
    route_table_id = aws_route_table.dtc_private_routes.id
    subnet_id= aws_subnet.dtc_private_subnet[count.index].id
}