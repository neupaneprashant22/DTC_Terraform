variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr"
}

variable "zone"{
    type=list(any)
}

variable "pub_cidr"{
    type=list(any)
}

variable "priv_cidr"{
    type=list(any)
}