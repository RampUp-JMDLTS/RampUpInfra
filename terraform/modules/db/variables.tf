variable "db_instance_identifier" {
  description = "The identifier for the database instance"
  type        = string

}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_engine" {
  description = "The database engine"
  type        = string
}

variable "db_engine_version" {
  description = "The database engine version"
  type        = string

}

variable "db_instance_class" {
  description = "The instance class for the database"
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
}

variable "db_parameter_group_name" {
  description = "The parameter group name for the database"
  type        = string

}

variable "subnet_ids" {
  description = "The subnet ids for the database"
  type        = list(string)

}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}