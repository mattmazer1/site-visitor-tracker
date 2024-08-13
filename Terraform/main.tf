terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = "value"
}

provider "aws" {
  region = "ap-southeast-2"
}

