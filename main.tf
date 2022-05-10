provider "aws" {
  region  = "us-east-1"
  alias = "acm_provider"
}

resource "aws_s3_bucket" "mybucket01" {
  bucket = "www.${var.bucket_name}"
  acl    = "public-read"
  #policy = file("Policy.json")
  

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = var.common_tags

}
resource "aws_s3_bucket" "mybucket02" {
  bucket = var.bucket_name
  acl    = "public-read"
  #policy = file("Policy.json")
  

  website {
    redirect_all_requests_to = "https://www.${var.domain_name}"
  }

  tags = var.common_tags

}

resource "aws_s3_bucket_object" "index" {
bucket = aws_s3_bucket.mybucket01.id
acl = "public-read" # or can be “public-read”
key = "index.html"
source = "./index.html"
etag = filemd5("./index.html")
content_type = "text/html"
}
resource "aws_s3_bucket_object" "error" {
bucket = aws_s3_bucket.mybucket01.id
acl = "public-read" # or can be “public-read”
key = "error.html"
source = "./error.html"
etag = filemd5("./error.html")
content_type = "text/html"
}

resource "aws_acm_certificate" "bitanawsproj" {
  domain_name               = "bitanawsproj.com"
  subject_alternative_names = ["www.bitanawsproj.com", "bitanawsproj.org"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "bitanawsproj" {
  name         = "bitanawsproj.com"
  private_zone = false
}

#data "aws_route53_zone" "bitanawsproj_org" {
#  name         = "bitanawsproj.org"
#  private_zone = false
#}

resource "aws_route53_record" "bitanawsproj" {
  for_each = {
    for dvo in aws_acm_certificate.bitanawsproj.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == "bitanawsproj.org" ? data.aws_route53_zone.bitanawsproj_org.zone_id : data.aws_route53_zone.bitanawsproj_com.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "bitanawsproj" {
  certificate_arn         = aws_acm_certificate.bitanawsproj.arn
  validation_record_fqdns = [for record in aws_route53_record.bitanawsproj : record.fqdn]
}
