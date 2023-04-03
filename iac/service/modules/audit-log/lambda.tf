module "audit_log_lambda" {
  source          = "../go-lambda"
  name            = "${var.name}-${terraform.workspace}-audit-log"
  lambda_name     = "${var.name}-${terraform.workspace}-audit-log"
  src_path        = "../../lib/audit-log" # terraform command is being ran out of ${project_root}/iac/service, thus you only navigate back 2 directories
  iam_policy_json = data.aws_iam_policy_document.audit_log_lambda_policy.json
}

data "aws_iam_policy_document" "audit_log_lambda_policy" {
  statement {
    actions = [
      "dynamodb:PutItem"
    ]
    effect   = "Allow"
    resources = [
      aws_dynamodb_table.last_stop_audit_log.arn
    ]
  }
}
