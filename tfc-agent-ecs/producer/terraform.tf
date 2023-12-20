terraform {
  cloud {
    organization = "hashidemos"

    workspaces {
      name = "tfc-agent-ecs-producer"
    }
  }
}