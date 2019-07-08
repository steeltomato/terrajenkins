variable "stack" {}
variable "private_subnets" {
  type = "list"
}

variable "ecs_ami" {}
variable "ec2_instance_type" {}

variable "ecs_security_group" {}

variable "crowdstrike_pkg_path" {}
variable "crowdstrike_pkg" {}
variable "qualys_pkg" {}

variable "artifactory_creds" {}

variable "efs_dns_name" {}

variable "ssh_key_name" {}