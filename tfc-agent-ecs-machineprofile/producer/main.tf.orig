provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "tfc_agent" {
  name = "${var.prefix}-cluster"
  tags = local.common_tags
}

resource "aws_ecs_service" "tfc_agent" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.tfc_agent.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.tfc_agent.arn
  desired_count   = var.desired_count
  network_configuration {
    security_groups  = [aws_security_group.tfc_agent.id]
    subnets          = [module.vpc.public_subnets[0]]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "tfc_agent" {
  family                   = "${var.prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.agent_init.arn
  task_role_arn            = aws_iam_role.agent.arn
  cpu                      = var.task_cpu
  memory                   = var.task_mem
  tags                     = local.common_tags
  container_definitions = jsonencode(
    [
      {
        name : "tfc-agent"
        image : "hashicorp/tfc-agent:latest"
        essential : true
        cpu : var.task_def_cpu
        memory : var.task_def_mem
        logConfiguration : {
          logDriver : "awslogs",
          options : {
            awslogs-create-group : "true",
            awslogs-group : "awslogs-tfc-agent"
            awslogs-region : var.region
            awslogs-stream-prefix : "awslogs-tfc-agent"
          }
        }
        environment = [
          {
            name  = "TFC_AGENT_SINGLE",
            value = "true"
          },
          {
            name  = "TFC_AGENT_NAME",
            value = "ECS_Fargate"
          }
        ]
        secrets = [
          {
            name      = "TFC_AGENT_TOKEN",
            valueFrom = aws_ssm_parameter.agent_token.arn
          }
        ]
      }
    ]
  )
}

resource "aws_ssm_parameter" "agent_token" {
  name        = "${var.prefix}-tfc-agent-token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.ecs_agent_pool_serviceB_token
}

# task execution role for agent init
resource "aws_iam_role" "agent_init" {
  name               = "${var.prefix}-ecs-tfc-agent-task-init-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "agent_init_policy" {
  role   = aws_iam_role.agent_init.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.agent_init_policy.json
}

resource "aws_iam_role_policy_attachment" "agent_init_policy" {
  role       = aws_iam_role.agent_init.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "agent_init_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.agent_token.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# task role for agent
resource "aws_iam_role" "agent" {
  name               = "${var.prefix}-ecs-tfc-agent-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "agent_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "agent_policy" {
  name = "${var.prefix}-ecs-tfc-agent-policy"
  role = aws_iam_role.agent.id

  policy = data.aws_iam_policy_document.agent_policy_definition.json
}

data "aws_iam_policy_document" "agent_policy_definition" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    #resources = [aws_iam_role.terraform_dev_role.arn]
    resources = ["arn:aws:iam::711129375688:role/*"]
  }
}

resource "aws_iam_role_policy_attachment" "agent_task_policy" {
  role       = aws_iam_role.agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# a role for terraform consumer to assume into
# you'll need to customize IAM policies to access resources as desired
resource "aws_iam_role" "terraform_dev_role" {
  name = "${var.prefix}-terraform_dev_role"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.dev_assume_role_policy_definition.json
}

data "aws_iam_policy_document" "dev_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = [aws_iam_role.agent.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "dev_ec2_role_attach" {
  role       = aws_iam_role.terraform_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.55.0"
  name    = "${var.prefix}-vpc"
  tags    = local.common_tags

  cidr = "10.0.0.0/16"

  azs            = ["${var.region}a"]
  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway = true
}

resource "aws_security_group" "tfc_agent" {
  name_prefix = "${var.prefix}-sg"
  description = "Security group for tfc-agent-vpc"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_egress" {
  security_group_id = aws_security_group.tfc_agent.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# lambda
resource "aws_lambda_function" "webhook" {
  function_name           = "${var.prefix}-webhook"
  description             = "Receives webhook notifications from TFC and automatically adjusts the number of tfc agents running."
  code_signing_config_arn = aws_lambda_code_signing_config.this.arn
  role                    = aws_iam_role.lambda_exec.arn
  handler                 = "main.lambda_handler"
  runtime                 = "python3.7"
  tags                    = local.common_tags

  s3_bucket = aws_s3_bucket.webhook.bucket
  s3_key    = aws_s3_bucket_object.webhook.id

  environment {
    variables = {
      CLUSTER        = aws_ecs_cluster.tfc_agent.name
      MAX_AGENTS     = var.max_count
      REGION         = var.region
      SALT_PATH      = aws_ssm_parameter.notification_token.name
      SERVICE        = aws_ecs_service.tfc_agent.name
      SSM_PARAM_NAME = aws_ssm_parameter.current_count.name
    }
  }
}

resource "aws_ssm_parameter" "current_count" {
  name        = "${var.prefix}-tfc-agent-current-count"
  description = "Terraform Cloud agent current count"
  type        = "String"
  value       = var.desired_count
}

resource "aws_ssm_parameter" "notification_token" {
  name        = "${var.prefix}-tfc-notification-token"
  description = "Terraform Cloud webhook notification token"
  type        = "SecureString"
  value       = var.notification_token
}

resource "aws_s3_bucket" "webhook" {
  bucket = "${var.prefix}-lambda-signed-code"
  acl    = "private"

  tags = local.common_tags
}

resource "aws_s3_bucket_object" "webhook" {
  bucket = aws_s3_bucket.webhook.id
  key    = "v${var.app_version}/webhook.zip"
  source = "${path.module}/files/webhook.zip"

  etag = filemd5("${path.module}/files/webhook.zip")
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.prefix}-webhook-lambda"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.webhook_assume_role_policy_definition.json
}

data "aws_iam_policy_document" "webhook_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  role   = aws_iam_role.lambda_exec.name
  name   = "${var.prefix}-lambda-webhook-policy"
  policy = data.aws_iam_policy_document.lambda_policy_definition.json
}

data "aws_iam_policy_document" "lambda_policy_definition" {
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

resource "aws_iam_role_policy_attachment" "cloudwatch_lambda_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.webhook.execution_arn}/*/*"
}

# api gateway
resource "aws_api_gateway_rest_api" "webhook" {
  name        = "${var.prefix}-webhook"
  description = "TFC webhook receiver for autoscaling tfc-agent"
  tags        = local.common_tags
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.webhook.id
  parent_id   = aws_api_gateway_rest_api.webhook.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.webhook.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.webhook.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.webhook.id
  resource_id   = aws_api_gateway_rest_api.webhook.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.webhook.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.webhook.invoke_arn
}

resource "aws_api_gateway_deployment" "webhook" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.webhook.id
  stage_name  = "test"
}

resource "aws_signer_signing_profile" "this" {
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "this" {
  allowed_publishers {
    signing_profile_version_arns = [
      aws_signer_signing_profile.this.arn,
    ]
  }

  policies {
    untrusted_artifact_on_deployment = "Warn"
  }
}