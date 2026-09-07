# ----------------------------------------
# Modules
# ----------------------------------------

# 通知先の SNS。EventBridge のターゲットはルールと同一リージョンにしか置けないため、
# 東京（リージョナルなイベント用）とバージニア北部（グローバルなイベント用）に1つずつ作る
module "notification" {
  source = "../../modules/notification"

  env            = var.env
  service_name   = var.service_name
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "notification_global" {
  source = "../../modules/notification"
  providers = {
    aws = aws.us_east_1
  }

  env            = var.env
  service_name   = var.service_name
  aws_account_id = data.aws_caller_identity.current.account_id
}

# 検知ルール。1ファイル1検知で modules/event-detector に並べてある
module "detector" {
  source = "../../modules/event-detector"
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  env          = var.env
  service_name = var.service_name

  sns_topic_arn        = module.notification.topic_arn
  sns_topic_arn_global = module.notification_global.topic_arn
}

# Slack 連携。ワークスペースの認可はコンソールでの手作業なので、
# slack_team_id / slack_channel_id が入るまでは作らない
module "chatbot" {
  source = "../../modules/chatbot"
  count  = var.slack_team_id == "" || var.slack_channel_id == "" ? 0 : 1
  providers = {
    aws = aws.us_east_1
  }

  env          = var.env
  service_name = var.service_name

  slack_team_id    = var.slack_team_id
  slack_channel_id = var.slack_channel_id
  sns_topic_arns = [
    module.notification.topic_arn,
    module.notification_global.topic_arn,
  ]
}
