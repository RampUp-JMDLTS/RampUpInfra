# EC2 Bastion Host variables
variable "public_key_path" {
  type = string
  default = "../SSH_KEYS/epam_key.pub"
}

variable "private_key_path" {
  type = string
  default = "../SSH_KEYS/epam_key"
}