variable aws_access_key {
  description = "The AWS access key."
}

variable aws_secret_key {
  description = "The AWS secret key."
}

variable region {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable ssh_pubkey_file {
  description = "Path to an SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
