provider "aws" {
  region  = "us-east-1"
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
resource "aws_s3_bucket_object" "index02" {
bucket = aws_s3_bucket.mybucket02.id
acl = "public-read" # or can be “public-read”
key = "index.html"
source = "./index.html"
etag = filemd5("./index.html")
content_type = "text/html"
}
resource "aws_s3_bucket_object" "error02" {
bucket = aws_s3_bucket.mybucket02.id
acl = "public-read" # or can be “public-read”
key = "error.html"
source = "./error.html"
etag = filemd5("./error.html")
content_type = "text/html"
}
