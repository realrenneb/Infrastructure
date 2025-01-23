# specify the required provider  used for http data fetching
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0.0"
}
# main_updated.tf
provider "aws" {
  region = "us-east-1"
} # Suitability of region can also be reviewed for migration dependant on latency, cost and required features
# Data source to fetch active users from REST API
data "http" "active_users" {
  url = "http://people-directory:8080/active"
  request_headers = {
    Accept = "application/json"
  }
}

# Data source to list existing S3 buckets
data "aws_s3_buckets" "user_buckets" {}

locals {
  active_users = jsondecode(data.http.active_users.response_body)
  existing_buckets = { for bucket in data.aws_s3_buckets.user_buckets.buckets : bucket => true }
}

# S3 bucket creation
resource "aws_s3_bucket" "user_buckets" {
  for_each = toset(local.active_users)
  
  bucket = each.key
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = lookup(local.existing_buckets, each.key, false)
  }

  tags = {
    Name        = each.key
    Environment = "Production"
    ManagedBy   = "EqvilentData"
    Team        = "Research"
    Project     = "ResearchUserBuckets"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.user_buckets
  
  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"  # Can be "Enabled" or "Suspended depending on requirements"
  }
}

# Set default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = aws_s3_bucket.user_buckets
  
  bucket = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Use AES256 encryption, can be updated to SSE-KMS 
    }
  }
}

# Configure lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rules" {
  for_each = aws_s3_bucket.user_buckets
  
  bucket = each.value.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Public access block for security
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = aws_s3_bucket.user_buckets
  
  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM policy for user access
resource "aws_iam_policy" "user_bucket_access" {
  for_each = aws_s3_bucket.user_buckets
  
  name = "s3-access-${each.key}"
  path = "/"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          each.value.arn,
          "${each.value.arn}/*"
        ]
      }
    ]
  })
}

output "bucket_details" {
  value = {
    for username, bucket in aws_s3_bucket.user_buckets : username => {
      bucket_name = bucket.id
      bucket_arn  = bucket.arn
      bucket_region = bucket.region
      encryption    = try(
        aws_s3_bucket_server_side_encryption_configuration.encryption[username].rule[0].apply_server_side_encryption_by_default.sse_algorithm,
        "Not configured"
      )
    }
  }
}