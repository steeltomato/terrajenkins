resource "aws_security_group" "load_balancer_security_group" {
  name        = "${var.stack}-lb-sg"
  vpc_id      = "${var.vpc}"
  description = "Access to the load balancer that sits in front of ECS"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* JNLP */
  ingress {
    from_port = 50000
    to_port   = 50000
    protocol  = "tcp"
    cidr_blocks = "${var.jnlp_whitelist}"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack}-load-balancers-sg"
  }
}

resource "aws_security_group" "ecs_host_security_group" {
  name        = "${var.stack}-ecs-host-sg"
  vpc_id      = "${var.vpc}"
  description = "Access to the ECS hosts and the tasks/containers that run on them"

  /* LB -> ECS */
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  // Uncomment to enable SSH access to EC2 hosts
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["216.37.8.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack}-ecs-hosts-sg"
  }
}

resource "aws_security_group" "jenkins_efs_sg" {
  name_prefix = "jenkins_master_efs"
  vpc_id      = "${var.vpc}"

  /* ECS -> EFS */
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_host_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack}-efs-sg"
  }
}

output "ecs_host_security_group_id" {
  value = "${aws_security_group.ecs_host_security_group.id}"
}

output "load_balancer_security_group_id" {
  value = "${aws_security_group.load_balancer_security_group.id}"
}
