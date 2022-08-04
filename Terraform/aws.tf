resource "aws_iam_role" "full_ec2" {
  name               = "full_ec2"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
}
resource "aws_iam_policy" "full_ec2" {
  name        = "full_ec2"
  description = "Allows ansible server full accesses to all ec2 instances."
  policy      = file("${path.module}/policies/fullec2.json")
}

resource "aws_iam_policy_attachment" "full_ec2" {
  name       = "full_ec2"
  roles      = [aws_iam_role.full_ec2.name]
  policy_arn = aws_iam_policy.full_ec2.arn
}

resource "aws_iam_instance_profile" "full_ec2" {
  name  = "full_ec2"
  role = aws_iam_role.full_ec2.name
}


resource "aws_acm_certificate" "kandula_cert" {

  domain_name  = "*.itzik-e.link"
  validation_method = "DNS"
  tags = {
    Name = "itzik-e.link"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
   timeouts {
     create = "15m"
   }
   certificate_arn         = aws_acm_certificate.kandula_cert.arn
   validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
 }

 resource "aws_route53_record" "cert_validation_record" {
   for_each = {
     for dvo in aws_acm_certificate.kandula_cert.domain_validation_options : dvo.domain_name => {
       name   = dvo.resource_record_name
       record = dvo.resource_record_value
       type   = dvo.resource_record_type
     }
   }

   allow_overwrite = true
   name            = each.value.name
   records         = [each.value.record]
   ttl             = 60
   type            = each.value.type
   zone_id         = "Z061465515L2AJIT0NO58"
 }