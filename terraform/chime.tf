resource "aws_chimesdkvoice_sip_media_application" "sip_media_application" {
  aws_region = var.region
  name       = join("-", compact([var.service_name, "sma"]))
  endpoints {
    lambda_arn = aws_lambda_function.sma_handler.arn
  }
}