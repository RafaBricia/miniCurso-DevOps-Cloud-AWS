terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.authentication.region

  default_tags {
    tags = var.tags
  }

  assume_role {
    role_arn = var.authentication.assume_role_arn
  }

}
