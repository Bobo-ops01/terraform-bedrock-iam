terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# What the role is allowed to do: call one model, nothing else
data "aws_iam_policy_document" "invoke_nova_micro" {
  statement {
    actions   = ["bedrock:InvokeModel"]
    resources = ["arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-micro-v1:0"]
  }
}

resource "aws_iam_policy" "invoke_nova_micro" {
  name   = "invoke-nova-micro-only"
  policy = data.aws_iam_policy_document.invoke_nova_micro.json
}

# Who is allowed to use the role: only your grace-admin user
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/grace-admin"]
    }
  }
}

resource "aws_iam_role" "bedrock_user" {
  name               = "bedrock-nova-micro-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.bedrock_user.name
  policy_arn = aws_iam_policy.invoke_nova_micro.arn
}

output "role_arn" {
  value = aws_iam_role.bedrock_user.arn
}
