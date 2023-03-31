module "audit_log_lambda" {
  source          = "./go-lambda"
  name            = "${var.name}-${terraform.workspace}-audit-log"
  lambda_name     = "${var.name}-${terraform.workspace}-audit-log"
  src_path        = "../../../../lib/audit-log"
  iam_policy_json = data.aws_iam_policy_document.audit_log_lambda_policy.json
}

data "aws_iam_policy_document" "audit_log_lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "none:null"
    ]
    resources = [
      "*"
    ]
  }
}