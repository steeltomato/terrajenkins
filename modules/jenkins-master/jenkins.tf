data "aws_caller_identity" "current" {}

locals {
  container_name       = "${var.stack}-master"
  container_definition = [{
    name             = "${local.container_name}"
    essential        = "true"
    image            = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.jenkins_repository}:${var.jenkins_image_tag}"
    portMappings     = [
      {
        containerPort = "8080"
        hostPort      = "8080"
      },
      {
        containerPort = "50000"
        hostPort      = "50000"
      }
    ]
    mountPoints      = [
      {
        containerPath = "/var/jenkins_home"
        sourceVolume  = "jenkins-efs"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        "awslogs-region"        = "${var.region}"
        "awslogs-group"         = "${var.log_group}"
        "awslogs-stream-prefix" = "default"
      }
    }
  }]
  def_json             = "${replace(replace(
    jsonencode(local.container_definition),
    "/\"(true|false|[[:digit:]]+)\"/", "$1"),
    "string:", "")}"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${local.container_name}"
  cpu                   = "${var.jenkins_master_cpu}"
  memory                = "${var.jenkins_master_memory}"
  execution_role_arn    = "${var.execution_role_arn}"
  task_role_arn         = "${var.task_role_arn}"
  container_definitions = "${local.def_json}"
  volume {
    name      = "jenkins-efs"
    host_path = "/jenkins-efs/jenkins_home"
  }
}

resource "aws_ecs_service" "service" {
  depends_on                         = ["null_resource.lb_exists", "null_resource.efs_exists"]
  name                               = "${local.container_name}"
  cluster                            = "${var.ecs_cluster_arn}"

  task_definition                    = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count                      = "1"
  deployment_minimum_healthy_percent = "0"
  deployment_maximum_percent         = "100"

  load_balancer {
    elb_name       = "${var.load_balancer_name}"
    container_name = "${local.container_name}"
    container_port = "8080"
  }
}

resource "null_resource" "lb_exists" {
  triggers {
    lb_arn = "${var.load_balancer_name}"
  }
}

resource "null_resource" "efs_exists" {
  triggers {
    lb_arn = "${var.efs_dns_name}"
  }
}

// TODO: Alerts
