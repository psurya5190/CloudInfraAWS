variable "cidr_block" {}
variable "aws_region" {
  default = "ap-south-1"
}
variable "aws_secret_key" {}
variable "aws_access_key" {}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  version    = "= 4.21.0"
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-caesar-tutorial-jenkins-5190"
    key     = "tutorial-jenkins/development/network/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins-instance-main_vpc"
  }
}



variable "private_subnets_count" {}
variable "public_subnets_count" {}
variable "availability_zones" {}
variable "public_subnets" {}
variable "public_key" {}

module "subnet_module" {
  source                = "./modules"
  vpc_id                = aws_vpc.main_vpc.id
  vpc_cidr_block        = aws_vpc.main_vpc.cidr_block
  availability_zones    = var.availability_zones
  public_subnets_count  = var.public_subnets_count
  private_subnets_count = var.private_subnets_count
  public_subnets        = var.public_subnets
  public_key            = var.public_key
}





/*

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
  "schemaVersion": "1.0",
  "description": "Document to hold regional settings for Session Manager",
  "sessionType": "Standard_Stream",
  "inputs": {
    "s3BucketName": "",
    "s3KeyPrefix": "",
    "s3EncryptionEnabled": true,
    "cloudWatchLogGroupName": "",
    "cloudWatchEncryptionEnabled": true,
    "cloudWatchStreamingEnabled": true,
    "idleSessionTimeout": "20",
    "maxSessionDuration": "",
    "kmsKeyId": "",
    "runAsEnabled": false,
    "runAsDefaultUser": "",
    "shellProfile": {
      "windows": "",
      "linux": ""
    }
  }
}
DOC
}

*/

