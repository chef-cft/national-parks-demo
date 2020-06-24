terraform {
  required_version = ">= 0.12"
  backend "s3" {
    # Comment below 4 lines
    # encrypt = true
    # bucket = "sa-s3-tf-backend"
    # region = "us-east-1"
    # key = "demo-validator/national-parks/terraform_state"
  }
}

provider "aws" {
  version = "~> 2.54"
  region                  = var.aws_region
  # Comment below 2 lines
  # profile                 = var.aws_profile
  # shared_credentials_file = "~/.aws/credentials"
}

# TODO: ghenkhaus, make sure this works
data "terraform_remote_state" "automate" {
  backend = "s3"
  config = {
    bucket = var.automate_backend_bucket
    key    = var.automate_backend_key
    region = var.automate_backend_region
  }
}

resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
// VPC 

resource "aws_vpc" "national_parks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Contact     = var.tag_contact
    X-Application = var.tag_application
    X-TTL         = var.tag_ttl
  }
}

resource "aws_internet_gateway" "national_parks_gateway" {
  vpc_id = aws_vpc.national_parks_vpc.id

  tags = {
    Name = "${var.tag_name}_national_parks_gateway-${var.tag_application}"
  }
}

resource "aws_route" "national_parks_internet_access" {
  route_table_id         = aws_vpc.national_parks_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.national_parks_gateway.id
}

resource "aws_subnet" "national_parks_subnet" {
  vpc_id                  = aws_vpc.national_parks_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name}_national_parks_subnet-${var.tag_application}"
  }
}

////////////////////////////////
// Instance Data

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}

