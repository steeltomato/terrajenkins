resource "aws_route53_record" "route" {
  zone_id = "${var.route_zone_id}"
  name    = "${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.load_balancer.dns_name}"]
}