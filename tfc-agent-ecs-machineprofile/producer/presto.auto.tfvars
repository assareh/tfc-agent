prefix        = "presto"
region        = "us-west-2"

desired_count = 2
max_count     = 4

# Pass these values from your workspace managing IAM creds and Tokens.
#   Use the remote_state datasource.
# Optionally, you can manually enter the information here.
#   FYI: You will need to uncomment lines in main.tf to reference these vars
ecs_agent_pool_serviceA_token = var.ecs_agent_pool_serviceA_token
ecs_agent_pool_serviceB_token = var.ecs_agent_pool_serviceB_token
ecs_init_serviceB_arn = "arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-task-init-role"
ecs_init_serviceA_arn = "arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-task-init-role"
#agent_init_id = "presto-ecs-tfc-agent-task-init-role"
aws_iam_role_agent_arn = "arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-role"
aws_iam_role_agent_id=""

