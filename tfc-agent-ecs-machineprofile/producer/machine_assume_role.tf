# TFC Agent Service using Machine IAM Profile assume_role instead of AWS TF Provider assume_role.
resource "aws_ecs_service" "tfc_agent_machine_profile" {
  name            = "${var.prefix}-machine_profile_svc"
  cluster         = aws_ecs_cluster.tfc_agent.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.tfc_agent_mprofile.arn
  desired_count   = var.desired_count
  network_configuration {
    security_groups  = [aws_security_group.tfc_agent.id]
    subnets          = [module.vpc.public_subnets[0]]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "tfc_agent_mprofile" {
  family                   = "${var.prefix}-tfc_agent_mprofile_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.agent_mprofile_init.arn
  task_role_arn            = aws_iam_role.serviceA_infra_role.arn
  cpu                      = var.task_cpu
  memory                   = var.task_mem
  tags                     = local.common_tags
  container_definitions = jsonencode(
    [
      {
        name : "tfc-agent-mprofile"
        image : "ppresto/tfc-agent"
        essential : true
        cpu : var.task_def_cpu
        memory : var.task_def_mem
        logConfiguration : {
          logDriver : "awslogs",
          options : {
            awslogs-create-group : "true",
            awslogs-group : "awslogs-tfc-agent"
            awslogs-region : var.region
            awslogs-stream-prefix : "awslogs-tfc-agent-mprofile"
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
            valueFrom = aws_ssm_parameter.agent_mprofile_token.arn
          }
        ]
      }
    ]
  )
}

resource "aws_ssm_parameter" "agent_mprofile_token" {
  name        = "${var.prefix}-agent_mprofile_token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.ecs_agent_pool_serviceA_token 
}

# task execution role for agent init
resource "aws_iam_role" "agent_mprofile_init" {
  name               = "${var.prefix}-ecs-tfc-agent_mprofile-task-init-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "agent_mprofile_init_policy" {
  role   = aws_iam_role.agent_mprofile_init.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.agent_mprofile_init_policy.json
}

resource "aws_iam_role_policy_attachment" "agent_mprofile_init_policy" {
  role       = aws_iam_role.agent_mprofile_init.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "agent_mprofile_init_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.agent_mprofile_token.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# a role for terraform consumer to assume into
# you'll need to customize IAM policies to access resources as desired
resource "aws_iam_role" "serviceA_infra_role" {
  name = "${var.prefix}-serviceA_infra_role"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.serviceA_assume_role_policy_definition.json
}

data "aws_iam_policy_document" "serviceA_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = ["*"]
      #identifiers = [aws_iam_role.agent_mprofile_init.arn]
      #identifiers = [aws_iam_role.agent.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "serviceA_attach_ec2" {
  role       = aws_iam_role.serviceA_infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}