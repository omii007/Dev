### variable declaration

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
	default = "tf"
}
variable "network_address_space" {
	default = "10.1.0.0/16"
}
variable "subnet1_address_space" {
	default = "10.1.0.0/24"
}
variable "subnet2_address_space" {
	default = "10.1.1.0/24"
}

### provider

provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "us-east-1"
}

### Data

data "aws_availability_zones" "available" {}

### resources

resource "aws_vpc" "vpc" {
	cidr_block = "${var.network_address_space}"
	enable_dns_hostname = "true"
}

resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "subnet1" {
	cidr_block = "${var.subnet1_address_sapce}"
	vpc_id = "${aws_vpc.vpc.id}"
	map_public_ip_on_launch = "true"
	availability_zones = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "subnet2" {
	cidr_block = "${var.subnet2_address_sapce}"
	vpc_id = "${aws_vpc.vpc.id}"
	map_public_ip_on_launch = "true"
	availability_zones = "${data.aws_availability_zones.available.names[1]}"
}

### routing config

resource "aws_route_table" "rtb" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
	  cide_block = "0.0.0.0/0"
	  gateway_id = "${aws_internet_gateway.igw.id}"
	}
}

resource "aws_route_table_association" "rta_subnet1" {
	subnet_id      = "${aws_subnet.subnet1.id}"
	route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta_subnet2" {
	subnet_id      = "${aws_subnet.subnet2.id}"
	route_table_id = "${aws_route_table.rtb.id}"
}

### security groyp
# Nginx security group

resource "aws_security_group" "nginx_sg" {
	name   = "nginx_sg"
	vpc_id = "${aws_vpc.vpc.id}"

	## ssh access from anywhere

	ingress {
	  from_port = 22
	  to_port = 22
	  protocol = "tcp"
	  cidr_block = ["0.0.0.0/0"]
	}
    
    ### http request from anywhere
    ingress {
	  from_port = 80
	  to_port = 80
	  protocol = "tcp"
	  cidr_block = ["0.0.0.0/0"]
	}

	egress {
	  from_port = 0
	  to_port = 0
	  protocol = "-1"
	  cidr_block = ["0.0.0.0/0"]
	}
}

## instances

resource "aws_instance" "nginx" {
	
	ami   = ""
	instance_type = "t2.micro"
	subnet_id = "${aws_subnet.subnet1.id}"
	vpc_security_group_id = ["${aws_security_group.nginx-sg.id}"]
}