job "tfc-agent" {
  datacenters = ["us-west-2"]
  type        = "service"

  group "tfc-agent" {
    count = 2

    vault {
      policies = ["tfc-agent"]
    }

    task "tfc-agent" {
      driver = "exec"

      config {
        command = "tfc-agent"
      }

      artifact {
        source = "https://releases.hashicorp.com/tfc-agent/0.1.8/tfc-agent_0.1.8_linux_amd64.zip"

        options {
          checksum = "sha256:5ff4a11084aee07b4bea3b1ba14fb81477b305b0cbb0b9477623d804b114479e"
        }
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
        cpu    = 500
        memory = 256
      }
    }
  }
}
