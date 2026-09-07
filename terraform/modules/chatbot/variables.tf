variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "slack_team_id" {
  type        = string
  description = "Slack ワークスペース ID。コンソールでワークスペースを認可すると発行される"
}

variable "slack_channel_id" {
  type        = string
  description = "通知先の Slack チャンネル ID"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "Chatbot に購読させる SNS トピック。リージョンをまたいで指定できる"
}
