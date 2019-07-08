variable "stack" {}
variable "region" {}

variable "ecr_arn" {}
variable "ecs_cluster_arns" {
  type = "list"
}
variable "cloudwatch_arn" {}
variable "load_balancer_arn" {}
