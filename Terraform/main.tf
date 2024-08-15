terraform {
  required_version = ">= 1.2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  cloud {
    organization = "Matts-personal-projects"

    workspaces {
      name = ""
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

