terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws3 = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
}
