variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  type        = string
}


variable "public_subnets" {
  description = "The public subnets of the VPC"
  type = list(object({
    name       = string
    zone       = string
    cidr_range = string
  }))
}

variable "private_subnets" {
  description = "The private subnets of the VPC"
  type = list(object({
    name       = string
    zone       = string
    cidr_range = string
  }))
}