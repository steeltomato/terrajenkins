resource "aws_efs_file_system" "jenkins_master" {
  creation_token = "${var.stack}-efs"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "jenkins_master" {
  count           = "${length(var.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.jenkins_master.id}"
  subnet_id       = "${var.private_subnets[count.index]}"
  security_groups = ["${aws_security_group.jenkins_efs_sg.id}"]
}

resource "alks_iamrole" "efs_backup_role" {
  name                     = "${var.stack}-backup"
  type                     = "AWS Backup"
  include_default_policies = true
}

//data "aws_iam_policy_document" "ecs_execution_role_policy_document" {
//  statement {
//    sid       = "EcrAuth"
//    effect    = "Allow"
//    actions   = [
//      "efs:GetAuthorizationToken"
//    ]
//    resources = [
//      "*"
//    ]
//  }
//}
//resource "aws_iam_role_policy" "ecs_execution_role_policy" {
//  name   = "${var.stack}-ecs-policy"
//  policy = "${data.aws_iam_policy_document.ecs_execution_role_policy_document.json}"
//  role   = "${alks_iamrole.ecs_execution_role.id}"
//}

resource "aws_backup_vault" "backup_vault" {
  name = "${var.stack}"
}

resource "aws_backup_plan" "backup_plan" {
  name = "${var.stack}"

  rule {
    rule_name         = "${var.stack}-jenkins"
    target_vault_name = "${aws_backup_vault.backup_vault.name}"
    schedule          = "cron(0 6 * * ? *)" // Daily at 6AM UTC

    lifecycle {
      delete_after = "7"
    }
  }
}

resource "aws_backup_selection" "example" {
  plan_id      = "${aws_backup_plan.backup_plan.id}"

  name         = "${var.stack}-efs"
  iam_role_arn = "${alks_iamrole.efs_backup_role.arn}"

  resources = [
    "${aws_efs_file_system.jenkins_master.arn}"
  ]
}

output "efs_dns_names" {
  value = "${aws_efs_mount_target.jenkins_master.*.dns_name}"
}
