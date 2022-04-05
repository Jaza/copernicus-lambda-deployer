resource "aws_iam_role" "copernicus_lambda_role" {
  name = "${var.environment}_copernicus_iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "copernicus_lambda_policy" {
  role       = aws_iam_role.copernicus_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "copernicus_api_lambda" {
  filename          = "modules/lambda/src/lambda_copernicus_api.zip"
  function_name     = "${var.environment}_copernicus_api_lambda"
  role              = "${aws_iam_role.copernicus_lambda_role.arn}"
  handler           = "index.handler"
  source_code_hash  = "${filebase64sha256("modules/lambda/src/lambda_copernicus_api.zip")}"
  runtime           = "nodejs14.x"

  environment {
    variables = {
      JWT_SECRET                   = "${var.jwt_secret}"
      DYNAMODB_TABLE_NAME_ACCOUNTS = "${var.environment}CopernicusAccounts"
      SWAGGER_PREFIX               = "/v1"
    }
  }
}

resource "aws_cloudwatch_log_group" "copernicus_lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.copernicus_api_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role_policy" "copernicus_lambda_dynamodb_policy" {
  name = "${var.environment}_copernicus_lambda_dynamodb_policy"
  role = aws_iam_role.copernicus_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = [
        "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.environment}CopernicusAccounts"
      ]
    }]
  })
}
