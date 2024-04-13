resource "aws_chimesdkvoice_sip_media_application" "sip_media_application" {
  aws_region = var.region
  name       = join("-", compact([var.service_name, "sma"]))
  endpoints {
    lambda_arn = aws_lambda_function.sma_handler.arn
  }
}

resource "aws_chime_voice_connector" "load_test" {
  name               = join("-", compact([var.service_name, "vc"]))
  require_encryption = false
  aws_region         = var.region
}

resource "aws_chime_voice_connector_origination" "emg_vc_origination" {
  disabled           = false
  voice_connector_id = aws_chime_voice_connector.load_test.id
  route {
    host     = aws_instance.sipp_server.public_ip
    port     = 5060
    protocol = "UDP"
    priority = 1
    weight   = 1
  }
}