terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.2"
}

# AWS Provider configuration

provider "aws" {
  region = "eu-central-1"
}

# AWS EC2 Resource creation

resource "aws_instance" "apache_server" {
  ami           = "ami-096a4fdbcf530d8e0"
  instance_type = "t2.micro"
  user_data     = file("user_data.sh")

  tags = {
    env = "dev"
  }
}
