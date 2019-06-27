# Providers

provider "aws" {
  region                  = "${var.region}"
  profile                 = "${var.profile}"
  shared_credentials_file = "$HOME/.aws/credentials"
  version                 = "~> 2.11"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hd-devops"

    workspaces {
      name = "sonarqube"
    }
  }
}
