terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. AWS ECR Repository for Application Images
resource "aws_ecr_repository" "app_ecr" {
  name                 = "devops-sample-app"
  image_tag_mutability = "MUTABLE"
  force_destroy        = true
}

# 2. Minimal Custom VPC for Testing
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "devops-lab-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "devops-lab-public-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_ecr.repository_url
}