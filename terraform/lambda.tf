resource "aws_lambda_function" "outbound_call" {
  function_name    = join("-", compact([var.service_name, "outbound-call"]))
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/dist/outbound-call/index.zip"
  source_code_hash = filebase64sha256("${path.module}/dist/outbound-call/index.zip")
  handler          = "index.lambdaHandler"
  runtime          = "nodejs18.x"
  timeout          = 15
  memory_size      = 512


  environment {
    variables = {
      REGION                   = var.region
      SIP_MEDIA_APPLICATION_ID = aws_chimesdkvoice_sip_media_application.sip_media_application.id
    }
  }
}

resource "aws_lambda_function" "sma_handler" {
  function_name    = join("-", compact([var.service_name, "sma-handler"]))
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/dist/sma-handler/index.zip"
  source_code_hash = filebase64sha256("${path.module}/dist/sma-handler/index.zip")
  handler          = "index.lambdaHandler"
  runtime          = "nodejs18.x"
  timeout          = 15
  memory_size      = 512
}

resource "aws_iam_role" "lambda_role" {
  name = var.service_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  inline_policy {
    name = "CreateChimeMeetingPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "chime:CreateSipMediaApplicationCall",
          ],
          Effect : "Allow"
          Resource : "*"
        }
      ]
    })
  }

  inline_policy {
    name = "EC2NetworkInterfacePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
          ],
          Effect : "Allow"
          Resource : "*"
        }
      ]
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}