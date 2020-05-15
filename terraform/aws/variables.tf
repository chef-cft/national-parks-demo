////////////////////////////////
// AWS Connection

variable "aws_profile" {
}

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

variable "tag_customer" {
}

variable "tag_project" {
}

variable "tag_name" {
}

variable "tag_dept" {
}

variable "tag_contact" {
}

variable "tag_application" {
}

variable "tag_ttl" {
  default = 4
}

variable "aws_key_pair_file" {
}

variable "aws_key_pair_name" {
}

variable "automate_server_instance_type" {
  default = "m5.xlarge"
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

variable "hab_install_opts" {
  default = ""
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
  default = "m5.xlarge"
}

variable "node_count" {
  default = "1"
}

variable "origin" {
}

variable "effortless_origin" {
  default = "effortless"
}

variable "effortless_infra" {
  default = "config-baseline"
}

variable "effortless_inspec" {
  default = "audit-baseline"
}

variable "group" {
  default = "default"
}

variable "update_strategy" {
  default = "at-once"
}

variable "update_condition" {
  default = "track-channel"
}

variable "health_check_interval" {
  default = "30"
}

variable "sleep" {
  default = "60"
}
variable "UPDATE_STRATEGY_FREQUENCY_MS" {
  default = "60000"
}

variable "HAB_AUTH_TOKEN" {
  default = "blankkey"
}

////////////////////////////////
// Automate Info 

variable "automate_url" {
}

variable "automate_token" {
}

variable "automate_user" {
}

variable "automate_ip" {
}

////////////////////////////////
// Automate EAS  

variable "hab-sup-version" {
  default = "core/hab-sup"
}

variable "event-stream-application" {
  default = "national-parks "
}

variable "event-stream-environment" {
  default = "demo"
}

