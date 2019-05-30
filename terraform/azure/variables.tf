variable "azure_region" {
  default = "eastus"
}

variable "azure_public_key_path" {
  default = "/path/to/ssh/key"
}

variable "azure_private_key_path" {
  default = "/path/to/ssh/key"
}

variable "azure_image_user" {
  default = "azureuser"
}

variable "azure_image_password" {}

variable "azure_sub_id" {
  default = "xxxxxxx-xxxx-xxxx-xxxxxxxxxx"
}

variable "azure_tenant_id" {
  default = "xxxxxxx-xxxx-xxxx-xxxxxxxxxx"
}

variable "application" {
  default = "nationalparks"
}

variable "origin" { }

variable "bldr_url" {
  default = "https://bldr.habitat.sh"
}

variable "channel" {
  default = "stable"
}

variable "group" {
  default = "default"
}

variable "update_strategy" {
  default = "at-once"
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

variable "count" {
  default = 1
}

variable "sleep" {
  default = "60"
}

variable "automate_url" {}

variable "automate_token" {}

variable "automate_user" {}