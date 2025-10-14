#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-$(aws configure get region || echo "us-east-1")}"
ENV="${ENV:-dev}"

command -v aws >/dev/null 2>&1 || { echo "aws CLI not found."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "terraform not found."; exit 1; }

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="petclinic-terraform-state-${AWS_ACCOUNT_ID}-${AWS_REGION}-${ENV}"
DYNAMO_TABLE="petclinic-terraform-lock-${AWS_ACCOUNT_ID}-${AWS_REGION}-${ENV}"

mkdir -p infra/boot
cat > infra/boot/provider.tf <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.5.0"
}
provider "aws" {
  region = "${AWS_REGION}"
}
EOF

cat > infra/boot/variables.tf <<EOF
variable "aws_region" { type = string, default = "${AWS_REGION}" }
variable "environment" { type = string, default = "${ENV}" }
variable "tf_state_bucket" { type = string, default = "${BUCKET_NAME}" }
variable "dynamodb_table" { type = string, default = "${DYNAMO_TABLE}" }
EOF

cat > infra/boot/main.tf <<'EOF'
resource "aws_s3_bucket" "tf_state" {
  bucket = var.tf_state_bucket
  acl    = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "expire-old-versions"
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = var.tf_state_bucket
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table
    Environment = var.environment
  }
}
EOF

cat > infra/boot/outputs.tf <<EOF
output "bucket" {
  value = aws_s3_bucket.tf_state.bucket
}
output "dynamodb_table" {
  value = aws_dynamodb_table.tf_lock.name
}
EOF

pushd infra/boot >/dev/null
terraform init -input=false
terraform apply -auto-approve -input=false
terraform output
popd >/dev/null
echo "Done. Check the bucket & table with 'aws s3 ls' and 'aws dynamodb describe-table'."
