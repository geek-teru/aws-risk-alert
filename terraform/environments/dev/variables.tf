variable "env" {
  type    = string
  default = "dev"
}

variable "service_name" {
  type    = string
  default = "aws-risk-alert"
}

# Slack ワークスペースの認可はコンソールでの手作業。
# 認可後に払い出される ID をここに入れると chatbot モジュールが作られる
variable "slack_team_id" {
  type    = string
  default = ""
}

variable "slack_channel_id" {
  type    = string
  default = ""
}

data "aws_caller_identity" "current" {}
