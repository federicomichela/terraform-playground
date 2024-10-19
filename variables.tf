variable "ec2_instance_name" {
  type = string                                 # The type of the variable, in this case a string
  default = "TP_EC2_Instance"          # Default value for the variable
  description = "Terraform Playground EC2 instance name tag value"   # Description of what this variable represents
}

variable "s3_instance_name" {
  type = string                                 # The type of the variable, in this case a string
  default = "TP_S3_Instance"          # Default value for the variable
  description = "Terraform Playground S3 instance name tag value"   # Description of what this variable represents
}

variable "s3_bucket_name" {
  type = string                                 # The type of the variable, in this case a string
  default = "tp-s3-bucket-"          # Default value for the variable
  description = "Terraform Playground S3 bucket name"   # Description of what this variable represents
}