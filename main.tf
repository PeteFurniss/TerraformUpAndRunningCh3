provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-up-and-running-state-pnfurniss"

    # Prevent accidental deletion of this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    # Enable versioning so we can see the full revision history of our state files
    versioning {
        enabled = true
    }

    # Enable server-side encrytion by default
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform-locks" {
    name         = "terraform-up-and-running-locks-pnfurniss"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket         = "terraform-up-and-running-state-pnfurniss"
        key            = "global/s3/terraform.tfstate"
        region         = "us-east-2"

        dynamodb_table = "terraform-up-and-running-locks-pnfurniss"
        encrypt        = true
    }
}

output "s3_bucket_arn" {
    value       = aws_s3_bucket.terraform_state.arn
    description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
    value       = aws_dynamodb_table.terraform-locks.name
    description = "The name of the DynamoDB table"
}
