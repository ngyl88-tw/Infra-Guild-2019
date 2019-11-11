variable "aws_profile" {
  type    = string
  default = null
}

variable "provisioner_key_name" {
  type    = string
}

variable "whitelisted_cidrs" {
  type    = list(string)
}

variable "ssh_public_key" {
  type    = string
  default = null
}