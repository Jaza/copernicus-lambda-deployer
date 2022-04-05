terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "${var.bucket}"
    key    = "copernicus.tfstate"
    region = "${var.region}"
  }
}

locals {
  environment = "${terraform.workspace}"
  region      = "${data.aws_region.current.name}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}

provider "aws" {}

module "lambda" {
  source      = "./modules/lambda"
  environment = "${local.environment}"
  region      = "${local.region}"
  account_id  = "${local.account_id}"
  jwt_secret  = "${var.jwt_secret}"
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = "${local.environment}"
}

module "api_gateway" {
  source                     = "./modules/api_gateway"
  environment                = "${local.environment}"
  region                     = "${local.region}"
  account_id                 = "${local.account_id}"
  copernicus_api_lambda_name = "${module.lambda.copernicus_api_lambda_name}"
}
