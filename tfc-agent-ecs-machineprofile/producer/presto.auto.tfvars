prefix        = "presto"
region        = "us-west-2"

desired_count = 2
max_count     = 4
ecs_agent_pool_serviceA_token = var.ecs_agent_pool_serviceA_token
ecs_agent_pool_serviceB_token = var.ecs_agent_pool_serviceB_token

# Pass these values from your workspace managing IAM creds.
#   Use the remote_state datasource.
# Optionally, you can manually enter the service role information here.
#   FYI: You will need to uncomment lines in the ECS definition to reference these vars ex: main.tf
agent_init_arn = "arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-task-init-role"
agent_init_id = "presto-ecs-tfc-agent-task-init-role"
aws_iam_role_agent_arn = "arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-role"
aws_iam_role_agent_id=""

