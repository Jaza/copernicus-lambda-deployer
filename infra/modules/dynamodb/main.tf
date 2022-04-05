resource "aws_dynamodb_table" "copernicus_accounts_table" {
  name           = "${var.environment}CopernicusAccounts"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "externalUserId"
  range_key      = "id"

  attribute {
    name = "externalUserId"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}
