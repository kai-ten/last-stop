resource "aws_cloudwatch_log_group" "apigw_logs" {
  name = "/${var.name}/api-gw/${terraform.workspace}"
}

resource "aws_iam_role" "apigw_role" {
  name = "${var.name}-apigw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "apigw_policy" {
  name = "${var.name}-apigw-policy"
  role = aws_iam_role.apigw_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution"
        ]
        Effect   = "Allow"
        Resource = module.step_function.state_machine_arn
      },
      {
        Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.apigw_logs.arn}"
      },
    ]
  })
}

locals {
  ports_in = [
    443,
    80
  ]
  ports_out = [
    443,
    80
  ]
}

resource "aws_security_group" "apigw_sg" {
  name        = "${var.name}-vpce-sg"
  description = "Security group for Last Stop REST API VPC Endpoint"
  vpc_id      = var.vpc_config.vpc_id
  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      description = "Web Traffic from network"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_config.vpc_cidr}"]
    }
  }
  dynamic "egress" {
    for_each = toset(local.ports_out)
    content {
      description = "Web Traffic to network"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_config.vpc_cidr}"]
    }
  }
}

resource "aws_vpc_endpoint" "apigw_endpoint" {
  vpc_id            = var.vpc_config.vpc_id # import or create VPC to deploy endpoint to
  service_name      = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.apigw_sg.id]

  subnet_ids = var.vpc_config.public_subnet_ids # import or create subnets to deploy endpoint to
}

resource "aws_api_gateway_rest_api" "last_stop_api" {
  name        = "${var.name}-API"
  description = "Last Stop REST API for Step Function integration"
}

resource "aws_api_gateway_resource" "last_stop_apigw_resource" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  parent_id   = aws_api_gateway_rest_api.last_stop_api.root_resource_id
  path_part   = "stepfunction"
}

resource "aws_api_gateway_method" "last_stop_apigw_method" {
  rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
  resource_id   = aws_api_gateway_resource.last_stop_apigw_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "last_stop_apigw_int" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_apigw_resource.id
  http_method = aws_api_gateway_method.last_stop_apigw_method.http_method
  

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:states:action/StartExecution"
  credentials            = "${aws_iam_role.apigw_role.arn}"

  request_templates = {
    "application/json" = <<EOF
  {
    "input": "$util.escapeJavaScript($input.json('$'))",
    "stateMachineArn": "${module.step_function.state_machine_arn}"
  }
    EOF
  }

  # {
  #   "input": "$util.escapeJavaScript($input.json('$'))",
  #   "stateMachineArn": "$util.escapeJavaScript($stageVariables.get(arn:aws:states:us-east-1:123456789012:stateMachine:HelloWorld))"
  # }
}

resource "aws_api_gateway_deployment" "last_stop_deployment" {
  depends_on = [aws_api_gateway_integration.last_stop_apigw_int]

  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  description = "Initial deployment"
}

resource "aws_api_gateway_stage" "last_stop_stage" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
  deployment_id = aws_api_gateway_deployment.last_stop_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn
    format          = jsonencode({
      "requestId":"$context.requestId",
      "extendedRequestId":"$context.extendedRequestId",
      "ip": "$context.identity.sourceIp",
      "caller":"$context.identity.caller",
      "user":"$context.identity.user",
      "requestTime":"$context.requestTime",
      "httpMethod":"$context.httpMethod",
      "resourcePath":"$context.resourcePath",
      "status":"$context.status",
      "protocol":"$context.protocol",
      "responseLength":"$context.responseLength"
    })
  }
}

resource "aws_api_gateway_method" "last_stop_options_method" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_apigw_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "last_stop_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_apigw_resource.id
  http_method = aws_api_gateway_method.last_stop_options_method.http_method
  status_code = 200

  /**
   * This is where the configuration for CORS enabling starts.
   * We need to enable those response parameters and in the 
   * integration response we will map those to actual values
   */
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  depends_on = [aws_api_gateway_method.last_stop_options_method]
}

resource "aws_api_gateway_integration" "last_stop_options_integration" {
    rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
    resource_id   = aws_api_gateway_resource.last_stop_apigw_resource.id
    http_method   = aws_api_gateway_method.last_stop_options_method.http_method
    type          = "MOCK"
    request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
    depends_on = [aws_api_gateway_method.last_stop_options_method]
}

resource "aws_api_gateway_integration_response" "last_stop_options_integration_response" {
    rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
    resource_id   = aws_api_gateway_resource.last_stop_apigw_resource.id
    http_method   = aws_api_gateway_method.last_stop_options_method.http_method
    status_code   = aws_api_gateway_method_response.last_stop_options_response_200.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [aws_api_gateway_method_response.last_stop_options_response_200]
}
