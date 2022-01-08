terraform {
  backend "s3" {
    bucket  = "mvana-account-terraform"
    key     = "failed-import-state"
    region  = "us-east-1"
    profile = "mvana"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "mvana"
}
