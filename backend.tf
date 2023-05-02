terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "1.4.19"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.0"
    }
  }
}

provider "nomad" {
  address = var.nomad_addr
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}
