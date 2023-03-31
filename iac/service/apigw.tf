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

resource "aws_vpc_endpoint" "apigw_endpoint" {
  vpc_id            = aws_vpc.main.id # import or create VPC to deploy endpoint to
  service_name      = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.apigw.id]

  subnet_ids = aws_subnet.private.*.id # import or create subnets to deploy endpoint to
}

resource "aws_security_group" "apigw" {
  name        = "${var.name}-vpce-sg"
  description = "Security group for Last Stop REST API VPC Endpoint"
  vpc_id      = aws_vpc.example.id # Reference existing VPC
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.name}-rest-api"
  description = "${var.name} REST API with AWS Step Functions integrations"

  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "step-function"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.step_function.state_machine_id
}

resource "aws_api_gateway_deployment" "v1_deployment" {
  depends_on = [aws_api_gateway_integration.example]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"
}

# Do we need VPC link?
# resource "aws_api_gateway_vpc_link" "example" { 
#   name        = "example-vpc-link"
#   target_arns = [aws_network_load_balancer.example.arn]
#   description = "Example VPC link for private REST API"
# }

resource "aws_cloudwatch_log_group" "api_logs" {
  name = "${var.name}-api-logs"

  tags = {
    Environment = "${var.env}"
    Application = "${var.name}"
  }
}


resource "aws_api_gateway_stage" "example" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.v1_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
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
