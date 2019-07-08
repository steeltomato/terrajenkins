/**
 *  This role is used by the services and inherited by the containers running in ECS
 */
resource "alks_iamrole" "ecs_execution_role" {
  name                     = "${var.stack}-ecs-exec-role"
  type                     = "Amazon EC2 Container Service Task Role"
  include_default_policies = true
}

data "aws_iam_policy_document" "ecs_execution_role_policy_document" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*"
    ]
    resources = ["${var.ecs_cluster_arns}"]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets"
    ]
    resources = [
      "${var.load_balancer_arn}"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      "${var.cloudwatch_arn}"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.stack}-ecs-policy"
  policy = "${data.aws_iam_policy_document.ecs_execution_role_policy_document.json}"
  role   = "${alks_iamrole.ecs_execution_role.id}"
}

output "ecs_execution_role_arn" {
  value = "${alks_iamrole.ecs_execution_role.arn}"
}
