terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.45"
    }
  }
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}
