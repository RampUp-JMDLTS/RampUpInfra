variable "allvms" {
  description = "All vms"
  type = list(object({
    name                 = string
    subnet_id            = string
    security_group       = string
    instance_type        = string
    source_dest_check    = optional(bool)
    iam_instance_profile = optional(string)
    public_ipv4          = optional(bool)
    key_name             = optional(string)
  }))
}