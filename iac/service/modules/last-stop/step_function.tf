locals {
  definition_template = <<EOF
{
  "Comment": "Store the query to an audit log",
  "StartAt": "Audit Log Service",
  "States": {
    "Audit Log Service": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${var.audit_log_lambda_arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Submit Query"
    },
    "Submit Query": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${var.gpt3cc_lambda_arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}

module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"
  name       = var.name
  definition = local.definition_template
  type = "EXPRESS"
  create_role = true

  service_integrations = {
    lambda = {
      lambda = [
        "${var.gpt3cc_lambda_arn}:*",
        "${var.audit_log_lambda_arn}:*"
      ]
    }

    # TODO: Adjust to use region, account number, and generate step function name AOT
    stepfunction_Sync = {
      stepfunction          = ["arn:aws:states:${var.region}:${var.account_id}:stateMachine:${var.name}"]
      stepfunction_Wildcard = ["arn:aws:states:${var.region}:${var.account_id}:stateMachine:${var.name}"]

      # Set to true to use the default events (otherwise, set this to a list of ARNs; see the docs linked in locals.tf
      # for more information). Without events permissions, you will get an error similar to this:
      #   Error: AccessDeniedException: 'arn:aws:iam::xxxx:role/step-functions-role' is not authorized to
      #   create managed-rule
      events = true
    }
  }
}
