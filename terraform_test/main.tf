provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "jdoe_bucket" {
  bucket = "jdoe"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "jdoe"
    Environment = "Production"
  }
}
resource "aws_s3_bucket" "asmith_bucket" {
  bucket = "asmith"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "asmith"
    Environment = "Production"
  }
}
resource "aws_s3_bucket" "pparker_bucket" {
  bucket = "pparker"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "pparker"
    Environment = "Production"
  }
}

output "bucket_names" {
  value = {
    "jdoe_bucket" = aws_s3_bucket.jdoe_bucket
    "asmith_bucket" = aws_s3_bucket.asmith_bucket
    "pparker_bucket" = aws_s3_bucket.pparker_bucket
  }
}