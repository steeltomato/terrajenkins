variable "stack" {}
variable "region" {}
variable "zones" {
  type = "list"
}

variable "vpc" {}
variable "private_subnets" {
  type = "list"
}
variable "public_subnets" {
  type = "list"
}

variable "ssl_certificate_arn" {}
variable "domain_name" {}
variable "route_zone_id" {}

variable "artifactory_creds" {}
variable "crowdstrike_pkg_path" {}
variable "crowdstrike_pkg" {}
variable "qualys_pkg" {}

variable "ecr_arn" {}

variable "ec2_instance_type" {}
variable "node_host_instance_type" {}

variable "jenkins_repository" {}
variable "jenkins_image_tag" {}

variable "jnlp_whitelist" {
  type = "list"
}