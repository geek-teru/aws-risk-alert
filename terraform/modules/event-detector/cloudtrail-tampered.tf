# ----------------------------------------
# CloudTrail の停止・削除・改変
#
# CloudTrail の API は証跡のあるリージョンで実行されるため、
# グローバルではなく通常の provider で作る
# ----------------------------------------
resource "aws_cloudwatch_event_rule" "cloudtrail_tampered" {
  name        = "${var.env}-${var.service_name}-cloudtrail-tampered"
  description = "CloudTrail の停止・削除・改変"

  event_pattern = jsonencode({
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["cloudtrail.amazonaws.com"]
      eventName   = ["StopLogging", "DeleteTrail", "UpdateTrail", "PutEventSelectors"]
    }
  })
}

resource "aws_cloudwatch_event_target" "cloudtrail_tampered" {
  rule      = aws_cloudwatch_event_rule.cloudtrail_tampered.name
  target_id = "sns"
  arn       = var.sns_topic_arn

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
