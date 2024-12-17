locals {
  instance_id  = "sns-${substr(sha256(var.instance_name), 0, 16)}"
  instructions = "Your SNS settings are set, but before you can send SMS messages you need to use the AWS console in ${var.region} to request a new Toll-Free Number and go through the registration process"
}

resource "aws_iam_role" "sns_success_feedback_role" {
  name = "${local.instance_id}-SuccessFeedback"
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
            "logs:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "passrole_policy" {
  name = "PassRolePolicy"
  description = "Policy to allow iam:PassRole on specific role"
  policy = jsonencode ({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "iam:PassRole",
        Effect = "Allow",
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sns-614c3d7c84b47455-SuccessFeedback"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_passrole" {
  user = ""
  policy_arn = aws_iam_policy.passrole_policy.arn
}

resource "aws_sns_sms_preferences" "sms_settings" {
  default_sender_id            = var.sender_id
  default_sms_type             = "Transactional"
  monthly_spend_limit          = var.monthly_spend_limit
  delivery_status_iam_role_arn = aws_iam_role.sns_success_feedback_role.arn
}
