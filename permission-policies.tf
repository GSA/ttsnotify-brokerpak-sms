# This Terraform code will create an AWS user named "ssb-${var.service_name}-broker" with the
# minimum policies in place that are needed for this brokerpak to operate.

variable "service_name" {
  type = string
  default = "sms"
}

locals {
  this_aws_account_id    = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

module "ssb_broker_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.2.0"

  create_iam_user_login_profile = false
  force_destroy                 = true
  name                          = "ssb-${var.service_name}-broker"
}

resource "aws_iam_user_policy_attachment" "broker_policies" {
  for_each = {
    // AWS SES policy defined below
    "broker_policy" = module.broker_policy.arn
    // Uncomment if we are still missing stuff and need to get it working again
    // "AdministratorAccess" = data.aws_iam_policy.administrator-access.arn
  }
  user       = module.ssb_broker_user.iam_user_name
  policy_arn = each.value
}

module "broker_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.2.0"

  name        = "${var.service_name}_broker"
  path        = "/"
  description = "${var.service_name} broker policy (covers SNS, IAM)"

  policy = <<-EOF
  {
    "Version":"2012-10-17",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Action": [
            "sns:GetSMSAttributes",
            "sns:SetSMSAttributes"
          ],
          "Resource":"*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "iam:CreateUser",
              "iam:DeleteUser",
              "iam:GetUser",

              "iam:CreateAccessKey",
              "iam:DeleteAccessKey",

              "iam:CreateRole",
              "iam:DeleteRole",
              "iam:GetRole",
              "iam:GetRolePolicy",
              "iam:PutRolePolicy",
              "iam:DeleteRolePolicy",

              "iam:GetUserPolicy",
              "iam:PutUserPolicy",
              "iam:DeleteUserPolicy",

              "iam:CreatePolicy",
              "iam:DeletePolicy",
              "iam:GetPolicy",
              "iam:AttachUserPolicy",
              "iam:DetachUserPolicy",

              "iam:List*"
          ],
          "Resource": "*"
        }
    ]
  }
  EOF
}
