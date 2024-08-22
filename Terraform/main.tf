terraform {
  required_version = ">= 1.2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.91.0"
    }
  }

  #init with state file and upload then delete state
  #   cloud {
  #     organization = "Matts-personal-projects"

  #     workspaces {
  #       name = ""
  #     }
  #   }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "hcp" {
  client_id     = var.HCP_CLIENT_ID
  client_secret = var.HCP_CLIENT_SECRET
}


variable "HCP_CLIENT_ID" {
  type = string
}

variable "HCP_CLIENT_SECRET" {
  type = string
}

module "frontend" {
  source = "./Frontend"
}
