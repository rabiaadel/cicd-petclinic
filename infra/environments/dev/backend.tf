terraform {
  backend "s3" {
    bucket         = "petclinic-tfstate-rabia"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "petclinic-tf-lock"
    encrypt        = true
  }
}
