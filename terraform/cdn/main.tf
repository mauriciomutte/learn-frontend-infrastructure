provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------------

locals {
  tags = {
    Name = "Example SPA Bucket",
    Environemnt = "production"
  }
  s3 = {
    name = "mutteground-spa-bucket"
  }
  cdn = {
    comment = "My SPA CloudFront CDN"
    aliases = ["teste.mauriciomutte.dev"]
  }
}

# ------------------------------------------------------------------------------------
# S3 - BUCKET SETUP
# ------------------------------------------------------------------------------------

resource "aws_s3_bucket" "mutte_bucket" {
  bucket        = local.s3.name
  force_destroy = false

  tags = local.tags
}

resource "aws_s3_bucket_acl" "mutte_bucket_acl" {
  bucket = aws_s3_bucket.mutte_bucket.id
  acl    = "private"
}

# ------------------------------------------------------------------------------------
# CloudFront - CDN SETUP
# ------------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "mutte_cdn_oac" {
  name = "mutte-cdn-oac"
  description = "OAC for ${aws_s3_bucket.mutte_bucket.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "mutte_cdn" {
  origin {
    origin_id   = aws_s3_bucket.mutte_bucket.bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.mutte_cdn_oac.id
    domain_name = aws_s3_bucket.mutte_bucket.bucket_regional_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.mutte_bucket.bucket
    compress               = true
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  comment             = local.cdn.comment
  default_root_object = "index.html"
  http_version        = "http2"
  price_class         = "PriceClass_All"
  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ------------------------------------------------------------------------------------
# S3 - POLICIES
# ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "allow_cdn_read_s3" {
	statement {
		actions = ["s3:GetObject"]
		resources = ["${aws_s3_bucket.mutte_bucket.arn}/*"]
		principals {
			type        = "Service"
			identifiers = ["cloudfront.amazonaws.com"]
		}
		condition {
			test     = "StringEquals"
			variable = "AWS:SourceArn"
			values   = [aws_cloudfront_distribution.mutte_cdn.arn]
		}
	}
}

data "aws_iam_policy_document" "s3_ssl_only" {
  statement {
    sid = "ForceSSLOnlyAccess"
    actions = ["s3:*"]
    effect = "Deny"
    resources = [
      aws_s3_bucket.mutte_bucket.arn,
      "${aws_s3_bucket.mutte_bucket.arn}/*"
    ]
    condition {
      test = "Bool"
      values = ["false"]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type = "*"
    }
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.s3_ssl_only.json,
    data.aws_iam_policy_document.allow_cdn_read_s3.json,
  ]
}

resource "aws_s3_bucket_policy" "mutte_bucket_policy_allow_cdn_read_s3" {
  bucket = aws_s3_bucket.mutte_bucket.id
  policy = data.aws_iam_policy_document.combined.json
}