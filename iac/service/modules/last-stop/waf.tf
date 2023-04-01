resource "aws_wafv2_web_acl" "last_stop_web_acl" {
  name  = "${var.name}-acl"
  scope = "CLOUDFRONT"
  provider = aws.east

  default_action {
    block {}
  }

#   rule {
    
#   }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf-metrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_ip_set" "last_stop_ip_set" {
  name               = "${var.name}-ip-set"
  provider = aws.east
  description        = "Last Stop IP set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["${var.vpc_config.vpc_cidr}"]
}
