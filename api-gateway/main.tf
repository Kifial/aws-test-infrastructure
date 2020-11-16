resource "aws_api_gateway_rest_api" "main" {
  name        = "tf-main"
  description = "Terraform Test API"
}

resource "aws_api_gateway_deployment" "dev" {
  depends_on = [aws_api_gateway_integration.test-proxy]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "dev"

  lifecycle {
    create_before_destroy = true
  }
}
