locals {
  user_name     = "sns-${var.region}-${var.user_name}"
  arn_partition = (var.region == "us-gov-west-1" ? "aws-us-gov" : "aws")
}

resource "aws_iam_user" "user" {
  name = local.user_name
  path = "/cf/"
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "user_policy" {
  name = format("%s-p", local.user_name)

  user = aws_iam_user.user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:${local.arn_partition}:sns:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
        Condition = {
          "ForAnyValue:IpAddress" = {
            "aws:SourceIp" = var.source_ips     # if we can publish on staging, why can't we filter?
          }
        }
      }
    ]
  })
}
