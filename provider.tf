terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 14.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_bearer_token
  insecure  = var.rancher_insecure
}
