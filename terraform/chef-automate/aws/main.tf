terraform {
  required_version = ">= 0.12"
  backend "s3" {
    # encrypt = true
    # bucket = "sa-s3-tf-backend"
    # region = "us-east-1"
    # key = "demo-validator/automate/terraform_state"
  }
}

provider "aws" {
  version = "~> 2.54"
  # region                  = "us-east-1"
  # profile                 = "solutions-architects"
  # shared_credentials_file = "/Users/gregoryhenkhaus/.aws/credentials"
}