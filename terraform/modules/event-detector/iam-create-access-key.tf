# ----------------------------------------
# アクセスキーの作成
#
# 呼び出し元では絞らず、CreateAccessKey を全件検知する
# IAM はグローバルサービスなので us-east-1 に記録される
# ----------------------------------------
resource "aws_cloudwatch_event_rule" "iam_create_access_key" {
  provider = aws.us_east_1

  name        = "${var.env}-${var.service_name}-iam-create-access-key"
  description = "アクセスキーの作成"

  event_pattern = jsonencode({
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = ["CreateAccessKey"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_create_access_key" {
  provider = aws.us_east_1

  rule      = aws_cloudwatch_event_rule.iam_create_access_key.name
  target_id = "sns"
  arn       = var.sns_topic_arn_global

  # Chatbot は「カスタム通知」形式の JSON しか Slack に転送しない。
  # また input_paths に無いフィールドを template で参照すると配信ごと失敗する
  input_transformer {
    input_paths = {
      account   = "$.account"
      region    = "$.region"
      time      = "$.time"
      eventName = "$.detail.eventName"
      userArn   = "$.detail.userIdentity.arn"
      sourceIp  = "$.detail.sourceIPAddress"
      userAgent = "$.detail.userAgent"
    }

    input_template = <<-EOT
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "textType": "client-markdown",
          "title": ":rotating_light: [CRITICAL] <eventName>",
          "description": "*アカウント*: <account>\n*リージョン*: <region>\n*発生時刻*: <time>\n*実行者*: <userArn>\n*送信元IP*: <sourceIp>\n*User-Agent*: <userAgent>"
        }
      }
    EOT
  }
}
