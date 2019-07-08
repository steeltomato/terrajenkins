/**
 * Respresents the role the Jenkins master ECS tasks will run under
 */

resource "alks_iamrole" "jenkins_master_role" {
  name                     = "${var.stack}-master-service"
  type                     = "Amazon EC2 Container Service Task Role"
  include_default_policies = true
}

data "aws_iam_policy_document" "jenkins_master_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:ListClusters",
      "ecs:DescribeContainerInstances",
      "ecs:RegisterTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:ListContainerInstances",
      "ecs:DescribeTasks"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]
    resources = [
      "${var.ecr_arn}"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      "*" // TODO: Refine
    ]
  }
}

resource "aws_iam_role_policy" "jenkins_service_role_policy" {
  name   = "${var.stack}-jenkins-master-role-policy"
  policy = "${data.aws_iam_policy_document.jenkins_master_role_policy_document.json}"
  role   = "${alks_iamrole.jenkins_master_role.id}"
}

output "jenkins_master_role_arn" {
  value = "${alks_iamrole.jenkins_master_role.arn}"
}
