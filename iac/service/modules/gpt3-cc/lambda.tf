module "gpt3cc_lambda" {
  source          = "../go-lambda"
  name            = "${var.name}-${terraform.workspace}-gpt3cc"
  lambda_name     = "${var.name}-${terraform.workspace}-gpt3cc"
  src_path        = "../../lib/gpt3-chat-completion" # terraform command is being ran out of ${project_root}/iac/service, thus you only navigate back 2 directories
  iam_policy_json = data.aws_iam_policy_document.gpt3cc_lambda_policy.json
  env_variables = {
    "OPENAPI_SECRET_NAME" = "/${var.name}-${terraform.workspace}/openapi/api_key"
  }
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
