variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "instance tyoe for terraform"
}

variable "ebs_volume" {
  default     = "8"
  description = "ebs volume"
}


variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "ebs volume"
}


variable "env" {
  type        = string
  default     = "prashant"
  description = "env"
}

variable "vpc_id"{
    default="vpc-0cfa6197ea89595f2"
}


