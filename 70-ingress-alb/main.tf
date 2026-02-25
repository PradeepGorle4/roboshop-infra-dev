module "alb" {
  source   = "terraform-aws-modules/alb/aws"
  internal = false
  # roboshop-dev-alb
  name                  = "${var.project_name}-${var.environment}-ingress-alb"
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  subnets               = local.public_subnet_ids
  create_security_group = false
  security_groups       = [local.alb_ingress_sg_id]
  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ingress-alb"
    }
  )
}

resource "aws_alb_listener" "https" {
    load_balancer_arn = module.alb.arn
    protocol = "HTTPS"
    port = "443"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = local.ingress_alb_certificate_arn

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/html"
        message_body = "<h1>Hello, Iam from Frontend web ALB with HTTPS</h1>"
        status_code = 200
      }

    }
}

resource "aws_route53_record" "ingress_alb" {
    zone_id = var.zone_id
    name = "*.${var.domain_name}"
    type = "A"

# These are APP ALB name and Zone ID information
    alias {
      name = module.alb.dns_name
      zone_id = module.alb.zone_id
      evaluate_target_health = true
    }
}


resource "aws_alb_listener_rule" "frontend" {
  listener_arn = aws_alb_listener.https.arn
  priority = 10

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["roboshop-${var.environment}.${var.domain_name}"] # so here, roboshop-dev-pradeepdevops.online
    }
  }
}

resource "aws_alb_target_group" "frontend" {
  name = local.resource_name
  port = "8080"
  protocol = "HTTP"
  vpc_id = local.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    protocol = "HTTP"
    port = "8080"
    path = "/"
    matcher = "200-299"
    interval = 10
  }
}