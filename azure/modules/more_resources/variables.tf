variable "location" {
  type        = string
  description = "Azure Region to deploy resources into"
  default     = "West US 2"
}

variable "resource_group_name" {
  type        = string
  description = "resource group to use"
}

variable "prefix" {
  type        = string
  description = "Prefix to place before deployed resources"
  default     = "cfy"
}

variable "client_id" {
  type        = string
  description = "Azure Client ID used for authentication"
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret used for authentication"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID used for authentication"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID used for authentication"
}
