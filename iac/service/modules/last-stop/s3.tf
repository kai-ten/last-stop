resource "random_string" "random" {
  length = 8
  lower = true
  special = false
  numeric = false
  upper = false
}

resource "aws_s3_bucket" "last_stop_website_bucket" {
  bucket = "${var.name}-${random_string.random.result}"
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.last_stop_website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "last_stop_website_bucket_config" {
  bucket = aws_s3_bucket.last_stop_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_config.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # subnet_ids = var.vpc_config.public_subnet_ids
  route_table_ids = var.vpc_config.public_route_table_ids
}

resource "aws_s3_bucket_policy" "last_stop_website_bucket_policy" {
  bucket = aws_s3_bucket.last_stop_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # {
      #   Principal = "*",
      #   Action = "s3:GetObject",
      #   Effect = "Allow",
      #   Resource = "${aws_s3_bucket.last_stop_website_bucket.arn}/*",
      #   Condition = {
      #     StringEquals = {
      #       "aws:sourceVpce": "${aws_vpc_endpoint.s3_endpoint.id}"
      #     }
      #   }
      # }
      ### The below supports Cloudfront
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Resource = "${aws_s3_bucket.last_stop_website_bucket.arn}/*"
        Principal = "*"
        Condition = {
          StringEquals = {
            "aws:sourceVpc" = "${var.vpc_config.vpc_id}"
          }
        }
      },
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Resource = "${aws_s3_bucket.last_stop_website_bucket.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:sourceArn" = "${aws_cloudfront_distribution.last_stop_distribution.arn}"
          }
        }
      }
    ]
  })
}
