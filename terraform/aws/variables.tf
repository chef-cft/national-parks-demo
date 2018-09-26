////////////////////////////////
// AWS Connection

variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "us-west-2"
}

////////////////////////////////
// Server Settings

variable "aws_centos_image_user" {
  default = "centos"
}

variable "aws_image_user" {
  default = "ubuntu"
}

variable "aws_amazon_image_user" {
  default = "ec2-user"
}

////////////////////////////////
// Tags

variable "tag_customer" {
  default = "chefconf2018"
}

variable "tag_project" {
  default = "chefconf2018"
}

variable "tag_name" {
  default = "chefconf2018"
}

variable "tag_dept" {
  default = "scottford"
}

variable "tag_contact" {
  default = "scott@scottford.io"
}

variable "tag_application" {
  default = "chefconfdemo"
}

variable "tag_ttl" {
  default = 3600
}

variable "aws_key_pair_file" {
  default = "~/.ssh/scottford"
}

variable "aws_key_pair_name" {
  default = "scottford"
}

variable "automate_server_instance_type" {
  default = "m4.xlarge"
}

variable "vpc_id" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

////////////////////////////////
// Habitat

variable "channel" {
  default = "stable"
}

variable "test_instance_type" {
  default = "t2.micro"
}

variable "dev_channel" {
  default = "unstable"
}

variable "prod_channel" {
  default = "stable"
}

variable "test_server_instance_type" {
  default = "m4.xlarge"
}

variable "count" {
  default = "1"
}

variable "origin" {}
