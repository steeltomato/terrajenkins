resource "aws_elb" "load_balancer" {
  name            = "${var.stack}-elb"
  subnets         = "${var.public_subnets}"
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "HTTP"
    lb_port = 443
    lb_protocol = "HTTPS"
    ssl_certificate_id = "${var.ssl_certificate_arn}"
  }

  listener {
    instance_port = 50000
    instance_protocol = "TCP"
    lb_port = 50000
    lb_protocol = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 70
    target              = "HTTP:8080/login"
    timeout             = 60
    unhealthy_threshold = 4
  }
}

//resource "aws_lb_listener" "load_balancer_listener" {
//  load_balancer_arn = "${aws_lb.load_balancer.arn}"
//  port              = 443
//  protocol          = "HTTPS"
//  ssl_policy		= "ELBSecurityPolicy-2016-08"
//  certificate_arn	= "${var.ssl_certificate_arn}"
//  "default_action" {
//    target_group_arn = "${aws_lb_target_group.default.arn}"
//    type             = "forward"
//  }
//}

output "load_balancer_name" {
  value = "${aws_elb.load_balancer.name}"
}

output "load_balancer_arn" {
  value = "${aws_elb.load_balancer.arn}"
}
