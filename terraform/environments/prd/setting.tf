# ----------------------------------------
# Provider Settings
# ----------------------------------------
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      env          = var.env
      service_name = var.service_name
      terraform    = "true"
    }
  }
}

# グローバルサービス（IAM / root のコンソールサインイン）のイベントは
# us-east-1 にしか記録されない。AWS Chatbot も同じ alias で作る
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      env          = var.env
      service_name = var.service_name
      terraform    = "true"
    }
  }
}

# ----------------------------------------
# Terraform Settings
# ----------------------------------------
terraform {
  required_version = "~> 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63.0"
    }
  }

  backend "s3" {
    # bucket / key はプロジェクトごとに変更する
    bucket  = "prd-terraform-aws"
    key     = "aws-risk-alert/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
