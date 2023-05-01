terraform {
  backend "azurerm" {

    resource_group_name  = "terraformstate"
    storage_account_name = "tstateaztreinamento"
    container_name       = "terraformstate"
    key                  = " chave do seu container "

  }
}


provider "azurerm" {
  # Configuration options
  features {

  }
}

variable "location" {
  type    = string
  default = "eastus"
}


resource "azurerm_resource_group" "rg" {
  name     = lower("rg-chicano123-${terraform.workspace}")
  location = var.location

}


resource "azurerm_service_plan" "planapp" {
  name                = lower("planappchicano123${terraform.workspace}")
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"

  //sku {
  //    tier = "Standard"
  //    size = "S1"
  //  }

  depends_on = [

    azurerm_resource_group.rg

  ]

}

resource "azurerm_linux_web_app" "webapp1" {
  name                = "appchicano123456project-${terraform.workspace}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.planapp.id

  site_config {
    application_stack {

      php_version = "7.4"

    }
  }


  app_settings = {
    "chave" = "123456"
  }

  depends_on = [

    azurerm_resource_group.rg,
    azurerm_service_plan.planapp

  ]


}





resource "azurerm_app_service_source_control" "repos-master" {
  app_id   = azurerm_linux_web_app.webapp1.id
  //use_local_git = true
  repo_url = "https://github.com/Ch1c4n0/samplephp"
  branch   = "master"

  //depends_on = [

  //  azurerm_resource_group.rg,
  //  azurerm_service_plan.planapp,
  //  azurerm_linux_web_app.webapp1

 // ]

}


resource "azurerm_linux_web_app_slot" "slot-test" {
  name           = "test-slot"
  app_service_id = azurerm_linux_web_app.webapp1.id

  site_config {
    application_stack {

      php_version = "7.4"

    }
  }
}



resource "azurerm_app_service_source_control_slot" "repos-slot" {
  slot_id  = azurerm_linux_web_app_slot.slot-test.id
  repo_url = "https://github.com/Ch1c4n0/samplephp"
  branch   = "master"
  //use_local_git = true
}


resource "azurerm_app_service_source_control_token" "token_de_acesso" {
  type  = "GitHub"
  token = "Token_do_seu_git"
}

output "url" {
  value = azurerm_linux_web_app.webapp1.default_hostname
}

output "url2" {
  value = azurerm_linux_web_app_slot.slot-test.default_hostname
}

output "ip" {
  value = azurerm_linux_web_app.webapp1.outbound_ip_addresses
}

