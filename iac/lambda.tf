module "data_filter_lambda" {
  source          = "./modules/go-lambda"
  name            = "${var.name}-${var.env}-data-filter"
  lambda_name     = "${var.name}-${var.env}-data-filter"
  src_path        = "../lib/data-filter"
  iam_policy_json = data.aws_iam_policy_document.data_filter_lambda_policy.json
}

data "aws_iam_policy_document" "data_filter_lambda_policy" {
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
