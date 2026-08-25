terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "tech-challenga-tfstate"
    key            = "infra-db/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tech-challenge-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Lê o state remoto do tech-challenge-infra-k8s para descobrir VPC e subnets
# onde o RDS deve ser provisionado — os dois repositórios compartilham a mesma VPC.
data "terraform_remote_state" "infra_k8s" {
  backend = "s3"

  config = {
    bucket = "tech-challenga-tfstate"
    key    = "infra-k8s/terraform.tfstate"
    region = "us-east-1"
  }
}
