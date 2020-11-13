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

# TODO: support multiple availability zones, and default to it.
variable availability_zone {
  description = "The availability zone"
  default = {
    "main"      = "eu-central-1a"
    "secondary" = "eu-central-1b"
  }
}

variable ecs_cluster_name {
  description = "The name of the Amazon ECS cluster."
  default     = "tf-test"
}

variable ssh_pubkey_file {
  description = "Path to an SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}