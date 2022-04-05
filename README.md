# Copernicus Lambda Deployer

Deploys the [Copernicus API](https://github.com/Jaza/copernicus-api) to AWS Lambda
(plus DynamoDB and API Gateway).

## Getting started

1. Fork, clone or download this project
1. Download latest Terraform (1.1.7 at time of writing) from
   https://www.terraform.io/downloads
1. Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION`
   environment variables per your AWS setup
1. Set the `TF_VAR_jwt_secret` environment variable to a secret value
1. At https://jwt.io/ you can generate a JWT based on that secret
1. Install and use nodejs 14.x (e.g. with `nvm use 14`)
1. `cd infra/modules/lambda/src`
1. `npm install`
1. `zip -r lambda_copernicus_api.zip index.js node_modules`
1. In the `infra` top-level directory, create a file called `backend.tfvars` with:
   `bucket = "name-of-s3-bucket-for-your-tfstate"`
   `region = "your-aws-region"`
1. `cd infra`
1. `terraform init -backend-config=backend.tfvars`
1. `terraform workspace new fooenv`
1. Run `terraform plan` to preview what will be deployed
1. Run `terraform apply` to deploy everything
1. You should be able to CRUD the Copernicus API at
   https://a1b2c3.execute-api.your-aws-region.amazonaws.com/v1/swagger-html/

Built by [Douugh](https://douugh.com/).
