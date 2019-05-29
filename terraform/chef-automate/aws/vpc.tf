resource "aws_vpc" "habmgmt-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Contact     = "${var.tag_contact}"
    X-Application = "${var.tag_application}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_internet_gateway" "habmgmt-gateway" {
  vpc_id = "${aws_vpc.habmgmt-vpc.id}"

  tags {
    Name = "habmgmt-gateway"
  }
}

resource "aws_route" "habmgmt-internet-access" {
  route_table_id         = "${aws_vpc.habmgmt-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.habmgmt-gateway.id}"
}

resource "aws_subnet" "habmgmt-subnet-a" {
  vpc_id                  = "${aws_vpc.habmgmt-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "habmgmt-subnet-a"
  }
}

resource "aws_subnet" "habmgmt-subnet-b" {
  vpc_id                  = "${aws_vpc.habmgmt-vpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "habmgmt-subnet-b"
  }
}
