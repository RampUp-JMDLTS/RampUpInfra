terraform {
  backend "s3" {
    encrypt                  = true
    bucket                   = "rampup-tfstate"
    key                      = "terraform.tfstate"
    region                   = "us-east-1"
    dynamodb_table           = "rampup-tflock"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "terraform-user"
  }
}