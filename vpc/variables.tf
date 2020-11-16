# TODO: support multiple availability zones, and default to it.
variable availability_zone {
  description = "The availability zone"
  default = {
    "main"      = "eu-central-1a"
    "secondary" = "eu-central-1b"
  }
}