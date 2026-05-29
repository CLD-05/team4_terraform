# Route53 호스팅 영역 생성
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-zone"
    team = "team4"
  }
}

# A 레코드 → ALB 연결 (루트 도메인)
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# www 서브도메인
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# ACM 인증서 DNS 검증 레코드
resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_359f30fb14adc0c24b142546743e19ee.singleuser.cloud"
  type    = "CNAME"
  ttl     = 300
  records = ["_f9ebfd7f6f5dae4d15393f8bf5de1838.jkddzztszm.acm-validations.aws."]
}
