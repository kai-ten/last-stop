output "bucket_url" {
  value = "http://${aws_s3_bucket.last_stop_website_bucket.bucket_domain_name}"
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.last_stop_distribution.domain_name
}
