terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      # グローバルサービス（IAM / root のコンソールサインイン）のイベントは
      # us-east-1 にしか記録されないため、その分だけ別 provider で作る
      configuration_aliases = [aws.us_east_1]
    }
  }
}
