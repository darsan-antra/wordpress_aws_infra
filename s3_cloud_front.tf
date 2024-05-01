
resource "aws_s3_bucket" "wordpressbucket141797test" {
  bucket = "wordpressbucket141798test"
  acl    = "private"
  versioning {
    enabled = true
  }
}

resource "aws_cloudfront_distribution" "wordpress_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.wordpressbucket141797test.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
