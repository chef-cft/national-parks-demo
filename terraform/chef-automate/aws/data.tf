
terraform {
<<<<<<< HEAD
  required_version = "= 0.11.14" // Terraform frequently puts breaking changes into minor and patch version releases. _Always_ hard pin to the latest known and tested working version. Do not trust semantic versioning.
=======
  required_version = "~> 0.11" // Terraform frequently puts breaking changes into minor and patch version releases. _Always_ hard pin to the latest known and tested working version. Do not trust semantic versioning.
>>>>>>> e3d697c6ce00e1e2b2226146dd11f9ab1245445d
}

provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}"
  shared_credentials_file = "${var.aws_credentials_file}"
}


resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
// Instance Data

data "aws_ami" "centos7" {
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "ubuntu16" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}