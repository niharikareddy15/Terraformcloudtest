provider "azurerm"{
    version           = ">=2.0.0"
    features {}
    subscription_id   = "${var.subscription_id}" 
    client_id         = "${var.client_id}"
    client_secret     = "${var.client_secret}"
    tenant_id         = "${var.tenant_id}"
}

variable "subscription_id" {
  description = "The Subscription Id of Azure"
}

variable "client_id" {
  description = "Client id of the app that you registered in AAD"
}

variable "client_secret" {
  description = "Client secret of the app that you registered in AAD"
}

variable "tenant_id" {
  description = "tenant id of the app that you registered in AAD"
}
