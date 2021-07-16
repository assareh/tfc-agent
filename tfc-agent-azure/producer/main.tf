provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_container_group" "tfc-agent" {
  name                = "tfc-agent"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = "tfc-agent"
    image  = "hashicorp/tfc-agent:latest"
    cpu    = "1.0"
    memory = "2.0"

    # this field seems to be mandatory (error happens if not there). See https://github.com/terraform-providers/terraform-provider-azurerm/issues/1697#issuecomment-608669422
    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      TFC_AGENT_SINGLE = "True"
    }

    secure_environment_variables = {
      TFC_AGENT_TOKEN = var.tfc_agent_token
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_subscription" "primary" {}

# you'll need to customize IAM policies to access resources as desired
resource "azurerm_role_assignment" "tfc-agent-role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_container_group.tfc-agent.identity[0].principal_id
}

# from here to EOF is optional, for azure function autoscaler
resource "azurerm_storage_account" "storage_account" {
  name                     = "tfcagentwebhooksa"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "tfc-agent-webhook-storage-container-functions"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name

  start  = "2021-01-01T00:00:00Z"
  expiry = "2022-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "tfc-agent-webhook-app-service-plan"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  kind                = "FunctionApp"
  reserved            = "true"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

data "local_file" "file_function_app" {
  filename = "${path.module}/function-app.zip"
}

resource "azurerm_storage_blob" "storage_blob" {
  name                   = filesha256(data.local_file.file_function_app.filename)
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
  source                 = data.local_file.file_function_app.filename
}

data "tfe_ip_ranges" "addresses" {}

resource "random_id" "function_name_suffix" {
  byte_length = 4
}

resource "azurerm_function_app" "function_app" {
  name                = "tfc-agent-webhook-function-app-${random_id.function_name_suffix.hex}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key,
    "AZURE_SUBSCRIPTION_ID"          = data.azurerm_subscription.primary.subscription_id,
    "AzureWebJobsDisableHomepage"    = "true",
    "CONTAINER_GROUP"                = azurerm_container_group.tfc-agent.name
    "FUNCTIONS_WORKER_RUNTIME"       = "python",
    "RESOURCE_GROUP"                 = data.azurerm_resource_group.rg.name
    "SALT"                           = var.notification_token,
    "WEBSITE_RUN_FROM_PACKAGE"       = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
  }
  identity {
    type = "SystemAssigned"
  }
  os_type = "linux"
  site_config {
    linux_fx_version          = "python|3.9"
    use_32_bit_worker_process = false
    dynamic "ip_restriction" {
      for_each = data.tfe_ip_ranges.addresses.notifications
      content {
        ip_address  = ip_restriction.value
      }
    }
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "tfc-agent-webhook-app-insights"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  application_type    = "other"
}

# give function permission to modify container group
resource "azurerm_role_assignment" "function-role" {
  scope                = azurerm_container_group.tfc-agent.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}
