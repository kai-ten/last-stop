resource "aws_wafv2_ip_set" "last_stop_internal_cidr_ip_set" {
  name = "internal-network-ip-set"
  description = "IP set for web ACL"
  scope = "CLOUDFRONT"
  provider = aws.east
  ip_address_version = "IPV4"
  addresses = [var.vpc_config.vpc_cidr]
}

resource "aws_wafv2_ip_set" "last_stop_custom_ipv4_ip_set" {
  name = "last-stop-custom-ipv4-network-ip-set"
  description = "Custom IPv4 set for web ACL"
  scope = "CLOUDFRONT"
  provider = aws.east
  ip_address_version = "IPV4"
  addresses = var.allowlistRangeIPv4
}

resource "aws_wafv2_ip_set" "last_stop_custom_ipv6_ip_set" {
  name = "last-stop-custom-ipv6-network-ip-set"
  description = "Custom IPv6 set for web ACL"
  scope = "CLOUDFRONT"
  provider = aws.east
  ip_address_version = "IPV6"
  addresses = var.allowlistRangeIPv6
}

resource "aws_wafv2_web_acl" "last_stop_web_acl" {
  name  = "${var.name}-acl"
  scope = "CLOUDFRONT"
  provider = aws.east

  default_action {
    block {}
  }

  rule {
    name = "internal-network-ip-rule"
    action {
      allow {}
    }
    priority = 1
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.last_stop_internal_cidr_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "last-stop-internal-cidr-network-ip-rule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name = "last-stop-custom-ipv4-network-ip-rule"
    action {
      allow {}
    }
    priority = 2
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.last_stop_custom_ipv4_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "last-stop-custom-ipv4-network-ip-rule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name = "last-stop-custom-ipv6-network-ip"
    action {
      allow {}
    }
    priority = 3
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.last_stop_custom_ipv6_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "last-stop-custom-ipv6-network-ip-rule"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf-metrics"
    sampled_requests_enabled   = true
  }
}
