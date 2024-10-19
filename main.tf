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

# Provider configuration for AWS
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"        # Alias for the us-west-1 region
  region = "us-west-1"
}

# EC2 instance resource (your existing resource)
resource "aws_instance" "app_server" {
  # ami           = "ami-0fff1b9a61dec8a5f" // aws
  ami           = "ami-0866a3c8686eaeeba" // linux
  instance_type = "t2.micro"

  tags = {
    Name = var.ec2_instance_name
  }
}

# S3 bucket resource
resource "aws_s3_bucket" "my_bucket" {
  provider = aws.west
  bucket = "tp-s3-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = var.s3_instance_name
    Environment = "Production"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}