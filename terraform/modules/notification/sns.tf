resource "aws_sns_topic" "alert" {
  name = "${var.env}-${var.service_name}-alert"
}

# EventBridge はロールを引き受けずサービスプリンシパルとして publish するので、
# 許可はトピック側のリソースベースポリシーに書く。
# aws:SourceAccount は、他アカウントの EventBridge から publish されるのを防ぐため
resource "aws_sns_topic_policy" "alert" {
  arn = aws_sns_topic.alert.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgePublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.alert.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aws_account_id
          }
        }
      }
    ]
  })
}

output "topic_arn" {
  value = aws_sns_topic.alert.arn
}
