variable "stack" {}
variable "vpc" {}
variable "private_subnets" {
  type = "list"
}
variable "public_subnets" {
  type = "list"
}
variable "ssl_certificate_arn" {}
variable "route_zone_id" {}
variable "domain_name" {}
variable "jnlp_whitelist" {
  type = "list"
}