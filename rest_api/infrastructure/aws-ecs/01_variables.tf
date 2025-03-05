variable "aws_account_id" {
  description = "Your AWS account ID"
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "aws_az1" {
  type    = string
  default = "eu-north-1a"
}

variable "aws_az2" {
  type    = string
  default = "eu-north-1b"
}
