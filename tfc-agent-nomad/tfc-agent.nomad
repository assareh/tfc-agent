job "tfc-agent" {
  datacenters = ["us-west-2"]
  type        = "service"

  group "tfc-agent" {
    count = 2

    vault {
      policies = ["tfc-agent"]
    }

    task "tfc-agent" {
      driver = "docker"

      config {
        image = "hashicorp/tfc-agent"
      }

      env {
        TFC_AGENT_SINGLE = "true"
        TFC_AGENT_NAME   = "my_tfc-agent_in_Nomad"
      }

      template {
        data = <<EOH
                   TFC_AGENT_TOKEN="{{with secret "secret/data/tfc-agent"}}{{.Data.data.TFC_AGENT_TOKEN}}{{end}}"
                   EOH

        destination = "secrets/config.env"
        env         = true
      }

      resources {
        memory = 256
      }
    }
  }
}
