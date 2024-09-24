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
    region= "us-east-1"
    access_key =""
    secret_key=""
  }
  
}

provider "aws" {
  region  = var.aws_region
  access_key =""
  secret_key=""
}

data "aws_ami" "ubuntu"{
  most_recent=true 
  filter{
    name="name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
   filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners=["099720109477"]
}
resource "aws_instance" "dtc_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "dtc_class1"
  vpc_security_group_ids=[aws_security_group.dtc_sg1.id]
  tags = {
    Name = "${var.env}-instance"
    Env = var.env
  }
}

resource "aws_security_group" "dtc_sg1"{
  vpc_id=var.vpc_id
  name="dtc vpc1"
  egress{
    from_port=0
    to_port=0
    protocol ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port=22
    to_port=22
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  

