data "aws_iam_policy_document" "chatbot_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "chatbot" {
  name               = "${var.env}-${var.service_name}-chatbot"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_chatbot_slack_channel_configuration" "alert" {
  configuration_name = "${var.env}-${var.service_name}"
  iam_role_arn       = aws_iam_role.chatbot.arn

  slack_team_id    = var.slack_team_id
  slack_channel_id = var.slack_channel_id
  sns_topic_arns   = var.sns_topic_arns

  logging_level = "ERROR"

  # 未指定だと AdministratorAccess が既定で当たる。
  # Slack から実行できる操作を読み取りに限定する
  guardrail_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
