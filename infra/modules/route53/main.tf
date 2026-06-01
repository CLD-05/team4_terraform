data "aws_lb" "prod_alb" {
  name = "team4-diaryapp-prod-alb"
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = {
    Name = "${var.project_name}-zone"
    team = "team4"
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = data.aws_lb.prod_alb.dns_name
    zone_id                = data.aws_lb.prod_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = data.aws_lb.prod_alb.dns_name
    zone_id                = data.aws_lb.prod_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_359f30fb14adc0c24b142546743e19ee.singleuser.cloud"
  type    = "CNAME"
  ttl     = 300
  records = ["_f9ebfd7f6f5dae4d15393f8bf5de1838.jkddzztszm.acm-validations.aws."]
}
