terraform {
  cloud {
    organization = "MrCrLr"

    workspaces {
      name = "tender-trap"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}