terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }

    local = {
      source = "hashicorp/local"
      version = "2.3.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terraform-user"
  region                   = "us-east-1"
}