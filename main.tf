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

# Providers configurations
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "aws" {
  alias  = "california"
  region = "us-west-1"
}

# EC2 instance resource
resource "aws_instance" "app_server" {
  provider = aws.virginia
  # ami           = "ami-0fff1b9a61dec8a5f" // aws
  ami           = "ami-0866a3c8686eaeeba" // linux
  instance_type = "t2.micro"

  tags = {
    Name        = var.s3_instance_name
    Environment = "Production"
  }
}

# S3 bucket for website
resource "aws_s3_bucket" "website_bucket" {
  provider = aws.virginia
  bucket   = "${var.s3_bucket_name}${random_id.bucket_suffix.hex}"

  tags = {
    Name        = var.s3_instance_name
    Environment = "Production"
  }
}

# Separate resource for website configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  provider = aws.virginia
  bucket   = aws_s3_bucket.website_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket policy for public access
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  provider = aws.virginia
  bucket   = aws_s3_bucket.website_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.website_bucket.id}/*"
    }
  ]
}
EOF
}

# Public access block for the bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  provider          = aws.virginia
  bucket            = aws_s3_bucket.website_bucket.id
  block_public_acls = true
  block_public_policy = false
}

# Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  provider = aws.virginia
  bucket   = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Random suffix to ensure unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# IAM policy for the infra-admin user, dynamically referencing the S3 bucket name
resource "aws_iam_policy" "s3_bucket_policy" {
  name   = "S3BucketAccess-${var.s3_bucket_name}${random_id.bucket_suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}/*"
        ]
      }
    ]
  })
}

# Attach the IAM policy to the infra-admin IAM user (or you could attach it to a role)
resource "aws_iam_user_policy_attachment" "attach_s3_policy" {
  user       = "infra-admin"  # Replace with your IAM user or role
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}