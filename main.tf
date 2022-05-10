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

# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  provider = aws.acm_provider
  domain_name = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  #validation_method = "EMAIL"
  validation_method = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "cert_validations" {

  zone_id = "Z09025261WQKPGHBA2IH5"
  #name    = element(aws_acm_certificate.ssl_certificate.domain_validation_options.*.resource_record_name, count.index)
  #type    = element(aws_acm_certificate.ssl_certificate.domain_validation_options.*.resource_record_type, count.index)
  #records = [element(aws_acm_certificate.ssl_certificate.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}
# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.acm_provider
  certificate_arn = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = aws_route53_record.cert_validations.*.fqdn
}

