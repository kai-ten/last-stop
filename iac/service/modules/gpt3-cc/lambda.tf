module "gpt3cc_lambda" {
  source          = ".go-lambda"
  name            = "${var.name}-${terraform.workspace}-gpt3cc"
  lambda_name     = "${var.name}-${terraform.workspace}-gpt3cc"
  src_path        = "../../../../lib/gpt3-chat-completion"
  iam_policy_json = data.aws_iam_policy_document.gpt3cc_lambda_policy.json
}

data "aws_iam_policy_document" "gpt3cc_lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "${aws_secretsmanager_secret.circulate_openapi_key.arn}"
    ]
  }
}
