terraform {
  cloud {
    organization = "irith-solutions"
    workspaces {
      name = "terraform-playground"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  # ami           = "ami-0fff1b9a61dec8a5f" // aws
  ami           = "ami-0866a3c8686eaeeba" // linux
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
