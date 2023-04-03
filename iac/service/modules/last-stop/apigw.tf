resource "aws_cloudwatch_log_group" "apigw_logs" {
  name = "/${var.name}/api-gw/${terraform.workspace}"
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
  cors_headers = {
    "Access-Control-Allow-Origin" = "'*'"
    "Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "Access-Control-Allow-Methods" = "'OPTIONS,GET,PUT,POST,DELETE'"
  }
  response_parameters = {
    for k, v in local.cors_headers : "method.response.header.${k}" => v
  }
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

  subnet_ids = var.vpc_config.public_subnet_ids
}

resource "aws_api_gateway_rest_api" "last_stop_api" {
  name        = "${var.name}-API"
  description = "Last Stop REST API for Step Function integration"
}

#### 
# Stepfunction - Resource, Method (POST), Response, Integration
####
resource "aws_api_gateway_resource" "last_stop_sfn_resource" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  parent_id   = aws_api_gateway_rest_api.last_stop_api.root_resource_id
  path_part   = "stepfunction"  
}

resource "aws_api_gateway_method" "last_stop_sfn_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
  resource_id   = aws_api_gateway_resource.last_stop_sfn_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "last_stop_sfn_post_response" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_sfn_resource.id
  http_method = aws_api_gateway_method.last_stop_sfn_post_method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = false
  }

  depends_on = [aws_api_gateway_method.last_stop_sfn_post_method]
}

resource "aws_api_gateway_integration" "last_stop_sfn_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_sfn_resource.id
  http_method = aws_api_gateway_method.last_stop_sfn_post_method.http_method
  
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:states:action/StartSyncExecution"
  credentials            = "${aws_iam_role.apigw_role.arn}"

  request_templates = {
    "application/json" = <<EOF
{
  "input": "$util.escapeJavaScript($input.json('$'))",
  "stateMachineArn": "${module.step_function.state_machine_arn}"
}
    EOF
  }
}

resource "aws_api_gateway_integration_response" "last_stop_sfn_post_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
  resource_id   = aws_api_gateway_resource.last_stop_sfn_resource.id
  http_method   = aws_api_gateway_method.last_stop_sfn_post_method.http_method
  status_code   = aws_api_gateway_method_response.last_stop_sfn_post_response.status_code

  response_parameters = local.response_parameters

  response_templates = {
    "application/json" = <<EOF
$util.parseJson($input.json('$.output'))
    EOF
  }
  depends_on = [aws_api_gateway_method_response.last_stop_sfn_post_response]
}

#######                                                      #######
######                                                        ######
#####                                                          #####
####                                                            ####
###                                                              ###
##                                                                ##
# Stepfunction - Resource, Method (OPTIONS), Response, Integration #
##                                                                ##
###                                                              ###
####                                                            ####
#####                                                          #####
######                                                        ######
#######                                                      #######
resource "aws_api_gateway_method" "last_stop_options_method" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_sfn_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "last_stop_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.last_stop_api.id
  resource_id = aws_api_gateway_resource.last_stop_sfn_resource.id
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
    "method.response.header.Access-Control-Allow-Credentials" = false
  }

  depends_on = [aws_api_gateway_method.last_stop_options_method]
}

resource "aws_api_gateway_integration" "last_stop_options_integration" {
    rest_api_id   = aws_api_gateway_rest_api.last_stop_api.id
    resource_id   = aws_api_gateway_resource.last_stop_sfn_resource.id
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
    resource_id   = aws_api_gateway_resource.last_stop_sfn_resource.id
    http_method   = aws_api_gateway_method.last_stop_options_method.http_method
    status_code   = aws_api_gateway_method_response.last_stop_options_response_200.status_code
 
    response_parameters = local.response_parameters
    depends_on = [aws_api_gateway_method_response.last_stop_options_response_200]
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "last_stop_deployment" {
  depends_on = [
    aws_api_gateway_integration.last_stop_sfn_post_integration,
    aws_api_gateway_integration.last_stop_options_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.last_stop_sfn_resource.id,
      aws_api_gateway_method.last_stop_sfn_post_method.id,
      aws_api_gateway_method.last_stop_options_method.id,
      aws_api_gateway_integration.last_stop_options_integration.id,
      aws_api_gateway_integration.last_stop_sfn_post_integration.id,
      aws_api_gateway_integration_response.last_stop_sfn_post_integration_response.id,
      aws_api_gateway_integration_response.last_stop_options_integration_response.id,
    ]))
  }

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