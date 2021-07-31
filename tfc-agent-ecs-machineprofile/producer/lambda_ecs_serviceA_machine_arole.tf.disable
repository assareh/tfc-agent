# lambda
resource "aws_lambda_function" "webhook-machine-arole" {
  function_name           = "${var.prefix}-webhook-machine-arole"
  description             = "Receives webhook notifications from TFC and automatically adjusts the number of tfc agents running."
  code_signing_config_arn = aws_lambda_code_signing_config.machine-arole.arn
  role                    = aws_iam_role.lambda_machine_arole_exec.arn
  handler                 = "main.lambda_handler"
  runtime                 = "python3.7"
  tags                    = local.common_tags

  s3_bucket = aws_s3_bucket.webhook-machine-arole.bucket
  s3_key    = aws_s3_bucket_object.webhook-machine-arole.id

  environment {
    variables = {
      CLUSTER        = aws_ecs_cluster.tfc_agent.name
      MAX_AGENTS     = var.max_count
      REGION         = var.region
      SALT_PATH      = aws_ssm_parameter.notification_token.name
      SERVICE        = aws_ecs_service.tfc_agent_machine_profile.name
      SSM_PARAM_NAME = aws_ssm_parameter.current_count.name
    }
  }
}

# aws_ssm_parameters are defined in main.tf lambda function

resource "aws_s3_bucket" "webhook-machine-arole" {
  bucket = "${var.prefix}-lambda-machine-arole-signed-code"
  acl    = "private"

  tags = local.common_tags
}

resource "aws_s3_bucket_object" "webhook-machine-arole" {
  bucket = aws_s3_bucket.webhook-machine-arole.id
  key    = "v${var.app_version}/webhook.zip"
  source = "${path.module}/files/webhook.zip"

  etag = filemd5("${path.module}/files/webhook.zip")
}

resource "aws_iam_role" "lambda_machine_arole_exec" {
  name = "${var.prefix}-webhook-machine-arole-lambda"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.webhook-machine-arole_assume_role_policy_definition.json
}

data "aws_iam_policy_document" "webhook-machine-arole_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "lambda_machine-role_policy" {
  role   = aws_iam_role.lambda_machine_arole_exec.name
  name   = "${var.prefix}-lambda-webhook-machine-arole-policy"
  policy = data.aws_iam_policy_document.lambda_machine-role_policy_definition.json
}

data "aws_iam_policy_document" "lambda_machine-role_policy_definition" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.notification_token.arn, aws_ssm_parameter.current_count.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:PutParameter"]
    resources = [aws_ssm_parameter.current_count.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["ecs:DescribeServices", "ecs:UpdateService"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_machine-role_attachment" {
  role       = aws_iam_role.lambda_machine_arole_exec.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_lambda_permission" "api-gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook-machine-arole.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.webhook-machine-arole.execution_arn}/*/*"
}

# api gateway
resource "aws_api_gateway_rest_api" "webhook-machine-arole" {
  name        = "${var.prefix}-webhook-machine-arole"
  description = "TFC webhook-machine-arole receiver for autoscaling tfc-agent"
  tags        = local.common_tags
}

resource "aws_api_gateway_resource" "proxy-machine-role" {
  rest_api_id = aws_api_gateway_rest_api.webhook-machine-arole.id
  parent_id   = aws_api_gateway_rest_api.webhook-machine-arole.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy-machine-role" {
  rest_api_id   = aws_api_gateway_rest_api.webhook-machine-arole.id
  resource_id   = aws_api_gateway_resource.proxy-machine-role.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-machine-role" {
  rest_api_id = aws_api_gateway_rest_api.webhook-machine-arole.id
  resource_id = aws_api_gateway_method.proxy-machine-role.resource_id
  http_method = aws_api_gateway_method.proxy-machine-role.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook-machine-arole.invoke_arn
}

resource "aws_api_gateway_method" "proxy-machine-role_root" {
  rest_api_id   = aws_api_gateway_rest_api.webhook-machine-arole.id
  resource_id   = aws_api_gateway_rest_api.webhook-machine-arole.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-machine-role_root" {
  rest_api_id = aws_api_gateway_rest_api.webhook-machine-arole.id
  resource_id = aws_api_gateway_method.proxy-machine-role_root.resource_id
  http_method = aws_api_gateway_method.proxy-machine-role_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook-machine-arole.invoke_arn
}

resource "aws_api_gateway_deployment" "webhook-machine-arole" {
  depends_on = [
    aws_api_gateway_integration.lambda-machine-role,
    aws_api_gateway_integration.lambda-machine-role_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.webhook-machine-arole.id
  stage_name  = "test"
}

resource "aws_signer_signing_profile" "machine-arole" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "machine-arole" {
  allowed_publishers {
    signing_profile_version_arns = [
      aws_signer_signing_profile.machine-arole.arn,
    ]
  }

  policies {
    untrusted_artifact_on_deployment = "Warn"
  }
}

output "webhook-machine-arole_url" {
  value = aws_api_gateway_deployment.webhook-machine-arole.invoke_url
}