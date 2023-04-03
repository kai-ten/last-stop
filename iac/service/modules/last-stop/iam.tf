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
          "states:StartExecution",
          "states:StartSyncExecution"
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
