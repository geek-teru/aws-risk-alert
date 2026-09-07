resource "aws_sns_topic" "alert" {
  name = "${var.env}-${var.service_name}-alert"
}

data "aws_iam_policy_document" "alert" {
  statement {
    sid    = "AllowEventBridgePublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alert.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account_id]
    }
  }
}

resource "aws_sns_topic_policy" "alert" {
  arn    = aws_sns_topic.alert.arn
  policy = data.aws_iam_policy_document.alert.json
}

output "topic_arn" {
  value = aws_sns_topic.alert.arn
}
