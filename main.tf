provider "aws" {
  region  = "us-east-1"
  alias = "acm_provider"
  alias = "account_route53"
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

# This data source looks up the public DNS zone
data "aws_route53_zone" "public" {
  name         = bitanawsproj.online
  private_zone = false
  provider     = aws.account_route53
}

# SSL Certificate
resource "aws_acm_certificate" "myapp" {
  provider = aws.acm_provider
  domain_name = aws_route53_record.myapp.fqdn
  subject_alternative_names = ["*.${var.domain_name}"]
  #validation_method = "EMAIL"
  validation_method = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
#resource "aws_acm_certificate_validation" "cert_validation" {
 resource "aws_route53_record" "cert_validation" { 
  allow_overwrite = true
  provider = aws.account_route53
  name            = tolist(aws_acm_certificate.myapp.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.myapp.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.myapp.domain_validation_options)[0].resource_record_type
  zone_id  = data.aws_route53_zone.public.id
  #certificate_arn = aws_acm_certificate.ssl_certificate.arn
  #validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  ttl=60
}
