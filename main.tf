terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
  backend "s3" {
    bucket = "dtc-terraform-states"
    key = "state"
    workspace_key_prefix="dtc_class"
    region="us-east-1"
    access_key =""
    secret_key=""
  }
  
}

provider "aws" {
  region  = "us-east-1"
  access_key =""
  secret_key=""
}

resource "aws_instance" "dtc_ec2" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name = "dtc_class1"
  tags = {
    Name = "uat instance"
    Env = "uat"
  }
}
