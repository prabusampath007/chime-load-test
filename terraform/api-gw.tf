resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.service_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "outbound_call" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "outboundCall"
}


resource "aws_api_gateway_method" "number_alias_rest_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.outbound_call.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "number_alias_rest_api_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.outbound_call.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.outbound_call.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.outbound_call.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  stage_description = "Deployed at ${timestamp()}"
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_resource.outbound_call.id))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "dev"
}