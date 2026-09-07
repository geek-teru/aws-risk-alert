# ----------------------------------------
# root ユーザーのコンソールログイン（成功・失敗とも）
#
# サインインはグローバルサービスのイベントなので us-east-1 に記録される
# ----------------------------------------
resource "aws_cloudwatch_event_rule" "root_console_login" {
  provider = aws.us_east_1

  name        = "${var.env}-${var.service_name}-root-console-login"
  description = "root ユーザーのコンソールログイン（成功・失敗とも）"

  event_pattern = jsonencode({
    "detail-type" = ["AWS Console Sign In via CloudTrail"]
    detail = {
      userIdentity = {
        type = ["Root"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "root_console_login" {
  provider = aws.us_east_1

  rule      = aws_cloudwatch_event_rule.root_console_login.name
  target_id = "sns"
  arn       = var.sns_topic_arn_global

  # Chatbot は「カスタム通知」形式の JSON しか Slack に転送しない。
  # また input_paths に無いフィールドを template で参照すると配信ごと失敗する
  input_transformer {
    input_paths = {
      account   = "$.account"
      region    = "$.region"
      time      = "$.time"
      userArn   = "$.detail.userIdentity.arn"
      sourceIp  = "$.detail.sourceIPAddress"
      userAgent = "$.detail.userAgent"
      result    = "$.detail.responseElements.ConsoleLogin"
    }

    input_template = <<-EOT
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "textType": "client-markdown",
          "title": ":rotating_light: [CRITICAL] root ユーザーのコンソールログイン (<result>)",
          "description": "*アカウント*: <account>\n*リージョン*: <region>\n*発生時刻*: <time>\n*実行者*: <userArn>\n*送信元IP*: <sourceIp>\n*User-Agent*: <userAgent>"
        }
      }
    EOT
  }
}
