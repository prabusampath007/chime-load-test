variable "service_name" {
  type    = string
  default = "chime-load-test"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "public_subnet_id" {

}