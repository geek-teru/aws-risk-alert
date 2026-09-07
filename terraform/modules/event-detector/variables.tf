variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "sns_topic_arn" {
  type        = string
  description = "リージョナルなイベントの通知先。ルールと同一リージョンである必要がある"
}

variable "sns_topic_arn_global" {
  type        = string
  description = "グローバルなイベントの通知先。us-east-1 のトピック"
}
