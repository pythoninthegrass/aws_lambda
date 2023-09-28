terraform {
  required_version = ">=0.12"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
