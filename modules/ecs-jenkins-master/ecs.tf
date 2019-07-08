resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.stack}-masters"
}

resource "alks_iamrole" "ecs_instance_role" {
  name                     = "${var.stack}-masters-instance-role"
  type                     = "Amazon EC2 Role for EC2 Container Service"
  include_default_policies = true
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

// This EC2 instance will only back the Jenkins master node container
// Jenkins does not support multiple masters
resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                      = "${var.stack}-masters-asg"
  max_size                  = "1"
  min_size                  = "1"
  vpc_zone_identifier       = "${var.private_subnets}"
  launch_configuration      = "${aws_launch_configuration.ecs_launch_configuration.name}"
  health_check_type         = "ELB"
  termination_policies      = [
    "OldestLaunchConfiguration",
    "ClosestToNextInstanceHour",
    "Default"]
  health_check_grace_period = 60 // Seconds
  default_cooldown          = 60 // Seconds

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/ecs_ec2_user_data.sh")}"
  vars {
    ecs_cluster_name = "${aws_ecs_cluster.ecs_cluster.name}"
    efs_dns_name     = "${var.efs_dns_name}"
    artifactory_creds = ""
    crowdstrike_pkg_path = ""
    crowdstrike_pkg = ""
    qualys_pkg = ""
  }
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  image_id                    = "${data.aws_ami.ecs_ami.id}"
  instance_type               = "${var.ec2_instance_type}"
  iam_instance_profile        = "${alks_iamrole.ecs_instance_role.ip_arn}"

  security_groups             = ["${var.ecs_security_group}"]

  user_data                   = "${data.template_file.user_data.rendered}"

  // Uncomment to enable SSH access to ec2 instances
  key_name                    = "${var.ssh_key_name}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

// TODO: Alerts

output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.ecs_cluster.arn}"
}

output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.ecs_cluster.name}"
}