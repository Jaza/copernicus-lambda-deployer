resource "aws_apigatewayv2_api" "copernicus_api" {
  name                         = "${var.environment}_copernicus_api"
  description                  = "Copernicus API"
  protocol_type                = "HTTP"
  version                      = "v0.1"
  disable_execute_api_endpoint = false
}

resource "aws_apigatewayv2_route" "copernicus_hello_world_route" {
  operation_name = "helloWorld"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "GET /"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_swagger_json_route" {
  operation_name = "swaggerJson"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "GET /swagger-json/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_swagger_html_route" {
  operation_name = "swaggerHtml"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "GET /swagger-html/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_list_accounts_route" {
  operation_name = "listAccounts"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "GET /external-users/{externalUserId}/accounts/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_create_account_route" {
  operation_name = "createAccount"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "POST /external-users/{externalUserId}/accounts/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_get_account_route" {
  operation_name = "getAccount"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "GET /external-users/{externalUserId}/accounts/{id}/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_update_account_route" {
  operation_name = "updateAccount"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "PATCH /external-users/{externalUserId}/accounts/{id}/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "copernicus_delete_account_route" {
  operation_name = "deleteAccount"
  api_id         = aws_apigatewayv2_api.copernicus_api.id
  route_key      = "DELETE /external-users/{externalUserId}/accounts/{id}/{proxy+}"
  target         = "integrations/${aws_apigatewayv2_integration.copernicus_lambda_integration.id}"
}

resource "aws_cloudwatch_log_group" "copernicus_api_log_group" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.copernicus_api.name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_stage" "copernicus_v1_stage" {
  api_id      = aws_apigatewayv2_api.copernicus_api.id
  name        = "v1"
  description = "Copernicus API v1"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.copernicus_api_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "copernicus_lambda_integration" {
  depends_on = [data.aws_lambda_function.copernicus_api_lambda]

  api_id           = aws_apigatewayv2_api.copernicus_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Copernicus API lambda integration"
  integration_method     = "POST"
  integration_uri        = "arn:aws:lambda:${var.region}:${var.account_id}:function:${data.aws_lambda_function.copernicus_api_lambda.function_name}"
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "allow_copernicus_api_permission" {
  for_each = toset([
    "",
    "swagger-json/{proxy+}",
    "swagger-html/{proxy+}",
    "external-users/{externalUserId}/accounts/{proxy+}",
    "external-users/{externalUserId}/accounts/{id}/{proxy+}"
  ])

  depends_on = [data.aws_lambda_function.copernicus_api_lambda]

  statement_id_prefix = "ExecuteByAPI"
  action              = "lambda:InvokeFunction"
  function_name       = "${data.aws_lambda_function.copernicus_api_lambda.function_name}"
  principal           = "apigateway.amazonaws.com"
  source_arn          = "${aws_apigatewayv2_api.copernicus_api.execution_arn}/*/*/${each.key}"
}
