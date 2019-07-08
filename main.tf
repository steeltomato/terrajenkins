terraform {
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

provider "alks" {
  url     = "https://alks.coxautoinc.com/rest"
  profile = "default"
}

provider "archive" {}
provider "template" {}

data "aws_canonical_user_id" "user" {}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.stack}"
  retention_in_days = 7
}

// Retrieve the latest ECS-optimized AMI
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [
      "amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = [
      "x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = [
      "hvm"]
  }
}

resource "aws_key_pair" "keypair" {
  key_name   = "ssh_key"
  public_key = "${file("/work/.terraform/id_rsa.pub")}"
}

module "infrastructure" {
  source              = "modules/infrastructure"
  stack               = "${var.stack}"
  vpc                 = "${var.vpc}"
  private_subnets     = "${var.private_subnets}"
  public_subnets      = "${var.public_subnets}"
  ssl_certificate_arn = "${var.ssl_certificate_arn}"
  domain_name         = "${var.domain_name}"
  route_zone_id       = "${var.route_zone_id}"
  jnlp_whitelist      = "${var.jnlp_whitelist}"
}

module "ecs_jenkins_master" {
  source               = "modules/ecs-jenkins-master"
  artifactory_creds    = "${var.artifactory_creds}"
  crowdstrike_pkg      = "${var.crowdstrike_pkg}"
  crowdstrike_pkg_path = "${var.crowdstrike_pkg_path}"
  ecs_ami              = "${data.aws_ami.ecs_ami.id}"
  ec2_instance_type    = "${var.ec2_instance_type}"
  ecs_security_group   = "${module.infrastructure.ecs_host_security_group_id}"
  private_subnets      = "${var.private_subnets}"
  qualys_pkg           = "${var.qualys_pkg}"
  stack                = "${var.stack}"
  efs_dns_name         = "${module.infrastructure.efs_dns_names[0]}"
  ssh_key_name         = "${aws_key_pair.keypair.key_name}"
}

module "ecs_jenkins_nodes" {
  source               = "modules/ecs-jenkins-nodes"
  artifactory_creds    = "${var.artifactory_creds}"
  crowdstrike_pkg      = "${var.crowdstrike_pkg}"
  crowdstrike_pkg_path = "${var.crowdstrike_pkg_path}"
  ecs_ami              = "${data.aws_ami.ecs_ami.id}"
  ec2_instance_type    = "${var.node_host_instance_type}"
  ecs_security_group   = "${module.infrastructure.ecs_host_security_group_id}"
  private_subnets      = "${var.private_subnets}"
  qualys_pkg           = "${var.qualys_pkg}"
  stack                = "${var.stack}"
  efs_dns_name         = "${module.infrastructure.efs_dns_names[0]}"
  ecs_node_min_hosts   = "1"
  ecs_node_max_hosts   = "10"
  ssh_key_name         = "${aws_key_pair.keypair.key_name}"
}

module "roles" {
  source            = "modules/roles"
  stack             = "${var.stack}"
  region            = "${var.region}"
  cloudwatch_arn    = "${aws_cloudwatch_log_group.log_group.arn}"
  ecr_arn           = "${var.ecr_arn}"
  ecs_cluster_arns  = ["${module.ecs_jenkins_master.ecs_cluster_arn}", "${module.ecs_jenkins_nodes.cluster_arn}"]
  load_balancer_arn = "${module.infrastructure.load_balancer_arn}"
}

module "jenkins_master" {
  source             = "modules/jenkins-master"
  stack              = "${var.stack}"
  region             = "${var.region}"
  vpc                = "${var.vpc}"
  log_group          = "${aws_cloudwatch_log_group.log_group.name}"
  ecs_cluster_arn    = "${module.ecs_jenkins_master.ecs_cluster_arn}"
  efs_dns_name       = "${module.infrastructure.efs_dns_names[0]}"
  execution_role_arn = "${module.roles.ecs_execution_role_arn}"
  task_role_arn      = "${module.roles.jenkins_master_role_arn}"
  jenkins_image_tag  = "${var.jenkins_image_tag}"
  jenkins_repository = "${var.jenkins_repository}"
  load_balancer_name = "${module.infrastructure.load_balancer_name}"
}

output "private_subnets" {
  value = "${var.private_subnets}"
}

output "ecs_host_security_group_id" {
  value = "${module.infrastructure.ecs_host_security_group_id}"
}

output "ecs_execution_role_arn" {
  value = "${module.roles.ecs_execution_role_arn}"
}
