provider "aws" {
  region  = "us-east-1"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "bitanawsproj.online"
  acl    = "public-read"
  policy = file("Policy.json")
  

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    Environment = "Terraform"
    Name        = "my-tag"
  }

}

resource "aws_s3_bucket_object" "index" {
bucket = aws_s3_bucket.mybucket.id
acl = "public-read" # or can be “public-read”
key = "index.html"
source = "./index.html"
etag = filemd5("./index.html")
content_type = "text/html"
}
resource "aws_s3_bucket_object" "error" {
bucket = aws_s3_bucket.mybucket.id
acl = "public-read" # or can be “public-read”
key = "error.html"
source = "./error.html"
etag = filemd5("./error.html")
content_type = "text/html"
}
