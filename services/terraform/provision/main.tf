locals {
  instructions = "Your SNS settings are set, but before you can send SMS messages you need to use the AWS console in ${var.region} to request a new Toll-Free Number and go through the registration process"
}

resource "aws_iam_role" "sns_success_feedback_role" {
  name = "SNSSuccessFeedback"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "cloudwatch_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_sns_sms_preferences" "sms_settings" {
  default_sender_id            = var.sender_id
  default_sms_type             = "Transactional"
  monthly_spend_limit          = var.monthly_spend_limit
  delivery_status_iam_role_arn = aws_iam_role.sns_success_feedback_role.arn
}

# resource "aws_pinpoint_app" "test" {}

# resource "aws_pinpoint_sms_channel" "sms_channel" {
#     application_id = aws_pinpoint_app.test.application_id
#     sender_id = var.sender_id
# }
