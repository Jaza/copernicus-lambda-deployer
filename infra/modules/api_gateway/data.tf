data "aws_lambda_function" "copernicus_api_lambda" {
  function_name = "${var.copernicus_api_lambda_name}"
}
