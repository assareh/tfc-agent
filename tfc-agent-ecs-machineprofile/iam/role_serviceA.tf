# a role for terraform consumer to assume into
# you'll need to customize IAM policies to access resources as desired
resource "aws_iam_role" "serviceA" {
  name = "iam-role-serviceA"
  tags = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_definition.json
}

resource "aws_iam_role_policy_attachment" "serviceA_attach" {
  role       = aws_iam_role.serviceA.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

output "iam_role_serviceA" {
  value = aws_iam_role.serviceA.arn
}