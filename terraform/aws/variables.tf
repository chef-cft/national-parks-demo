////////////////////////////////
// AWS Connection

variable "aws_profile" {}

variable "aws_region" {
  default = "us-west-2"
}

////////////////////////////////
// Server Settings

variable "aws_centos_image_user" {
  default = "centos"
}

variable "aws_ami_user" {
  default = "centos"
}

variable "aws_amazon_image_user" {
  default = "ec2-user"
}

////////////////////////////////
// Tags

variable "tag_customer" {}

variable "tag_project" {}

variable "tag_name" {}

variable "tag_dept" {}

variable "tag_contact" {}

variable "tag_application" {}

variable "tag_ttl" {
  default = 4
}

variable "aws_key_pair_file" {}

variable "aws_key_pair_name" {}

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


variable "group" {
  default = "default"
}

variable "update_strategy" {
  default = "at-once"
}


