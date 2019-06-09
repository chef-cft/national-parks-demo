resource "aws_lb" "chef_automate" {
  load_balancer_type = "application"
  name               = "chef-automate-${random_id.instance_id.hex}"
  internal           = "false"
  security_groups    = ["${aws_security_group.chef_automate.id}"]
  subnets            = ["${aws_subnet.habmgmt-subnet-a.id}","${aws_subnet.habmgmt-subnet-b.id}"]
  tags               = {
    Name               = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_alb"
    X-Dept             = "${var.tag_dept}"
    X-Customer         = "${var.tag_customer}"
    X-Project          = "${var.tag_project}"
    X-Application      = "${var.tag_application}"
    X-Contact          = "${var.tag_contact}"
    X-TTL              = "${var.tag_ttl}"
  }
}

resource "aws_lb_target_group" "chef_automate" {
  name                 = "${random_id.instance_id.hex}"
  vpc_id               = "${aws_vpc.habmgmt-vpc.id}"
  port                 = "443"
  protocol             = "HTTPS"

  depends_on = ["aws_lb.chef_automate"]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "chef_automate" {
  domain   = "${var.automate_alb_acm_matcher}"
  statuses = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "chef_automate" {
  load_balancer_arn = "${aws_lb.chef_automate.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.chef_automate.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.chef_automate.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "chef_automate" {
  listener_arn    = "${aws_lb_listener.chef_automate.arn}"
  certificate_arn = "${data.aws_acm_certificate.chef_automate.arn}"
}

resource "aws_lb_target_group_attachment" "chef_automate" {
  target_group_arn = "${aws_lb_target_group.chef_automate.arn}"
  target_id        = "${aws_instance.chef_automate.id}"
  port             = 443
}

data "aws_route53_zone" "selected" {
  name = "${var.automate_alb_r53_matcher}"
}

resource "aws_route53_record" "chef_automate" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.automate_hostname}"
  type    = "CNAME"
  ttl     = "30"
  records = ["${aws_lb.chef_automate.dns_name}"]
}

