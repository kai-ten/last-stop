terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.45"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  profile = "default"

  default_tags {
    tags = {
      Name = "Circulate - Last Stop"
    }
  }
}
