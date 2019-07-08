resource "aws_ecs_cluster" "jenkins_nodes_cluster" {
  name = "${var.stack}-nodes"
}

resource "alks_iamrole" "jenkins_nodes_instance_role" {
  name                     = "${var.stack}-nodes-instance-role"
  type                     = "Amazon EC2 Role for EC2 Container Service"
  include_default_policies = true
}

data "template_file" "jenkins_nodes_user_data" {
  template = "${file("${path.module}/jenkins_nodes_ec2_user_data.sh")}"
  vars {
    ecs_cluster_name     = "${aws_ecs_cluster.jenkins_nodes_cluster.name}"
    artifactory_creds    = ""
    crowdstrike_pkg_path = ""
    crowdstrike_pkg      = ""
    qualys_pkg           = ""
  }
}

resource "aws_launch_template" "jenkins_nodes_launch_template" {
  name                                 = "${var.stack}-nodes"
  image_id                             = "${var.ecs_ami}"
  instance_type                        = "${var.ec2_instance_type}"
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids               = ["${var.ecs_security_group}"]

  iam_instance_profile {
    arn = "${alks_iamrole.jenkins_nodes_instance_role.ip_arn}"
  }

  block_device_mappings {
    device_name = "xvdb"
    ebs {
      volume_type           = "standard"
      volume_size           = 100 // 100 GB, intentionally large due to docker image/container cache
      delete_on_termination = true
    }
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }

  key_name                             = "${var.ssh_key_name}"
  user_data                            = "${base64encode(data.template_file.jenkins_nodes_user_data.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "jenkins_nodes_placement_group" {
  name     = "${var.stack}-nodes"
  strategy = "partition" // Spread across AZs
}

resource "aws_autoscaling_group" "jenkins_nodes_autoscaling_group" {
  name                      = "${var.stack}-nodes-asg"
  max_size                  = "${var.ecs_node_max_hosts}"
  min_size                  = "${var.ecs_node_min_hosts}"
  vpc_zone_identifier       = "${var.private_subnets}"
  health_check_type         = "ELB"
  termination_policies      = [
    "OldestLaunchConfiguration",
    "ClosestToNextInstanceHour",
    "Default"]
  health_check_grace_period = 60
  default_cooldown          = 60
  placement_group           = "${aws_placement_group.jenkins_nodes_placement_group.id}"

  launch_template {
    id      = "${aws_launch_template.jenkins_nodes_launch_template.id}"
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}

resource "aws_autoscaling_policy" "ecs_cpu_autoscaling_policy" {
  autoscaling_group_name    = "${aws_autoscaling_group.jenkins_nodes_autoscaling_group.name}"
  name                      = "${var.stack}-nodes-cpu-autoscaling-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = "${aws_ecs_cluster.jenkins_nodes_cluster.name}"
      }
      metric_name = "CPUReservation"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = "80"
  }
}

resource "aws_autoscaling_policy" "ecs_memory_autoscaling_policy" {
  autoscaling_group_name    = "${aws_autoscaling_group.jenkins_nodes_autoscaling_group.name}"
  name                      = "${var.stack}-nodes-memory-autoscaling-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = "${aws_ecs_cluster.jenkins_nodes_cluster.name}"
      }
      metric_name = "MemoryReservation"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = "70"
  }
}

// TODO: Alerts

output "cluster_arn" {
  value = "${aws_ecs_cluster.jenkins_nodes_cluster.arn}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.jenkins_nodes_cluster.name}"
}