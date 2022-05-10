terraform {
  

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "yourdomain-terraform"
    key = "prod/terraform.tfstate"
    region = "eu-east-1"
  }
}

provider "aws" {
  region = "eu-east-1"
}

provider "aws" {
  alias = "acm_provider"
  region = "us-east-1"
}