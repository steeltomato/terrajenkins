variable "stack" {}
variable "region" {}
variable "vpc" {}
variable "log_group" {}

variable "ecs_cluster_arn" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "load_balancer_name" {}
variable "efs_dns_name" {}

variable "jenkins_repository" {}
variable "jenkins_image_tag" {}
variable "jenkins_master_cpu" {
  default = 2048
}
variable "jenkins_master_memory" {
  default = 1800
}