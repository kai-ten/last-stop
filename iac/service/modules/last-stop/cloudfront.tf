locals {
  s3_origin_id = "LastStopS3Origin"
}

resource "aws_cloudfront_origin_access_control" "last_stop_oac" {
  name                              = "${var.name}-oac"
  description                       = "Origin Access Control Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "last_stop_distribution" {
  origin {
    domain_name = aws_s3_bucket.last_stop_website_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id 
    origin_access_control_id = aws_cloudfront_origin_access_control.last_stop_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for Last Stop website"
  default_root_object = "index.html"
  web_acl_id = aws_wafv2_web_acl.last_stop_web_acl.arn
    #  aliases = [ "value" ] link route53

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


