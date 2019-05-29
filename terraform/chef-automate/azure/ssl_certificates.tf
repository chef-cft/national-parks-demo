provider "acme" {
  server_url = "${var.acme_provider_url}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.tag_contact}"
}

resource "acme_certificate" "automate_cert" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "${azurerm_dns_a_record.automate_lb_dns.name}.${azurerm_dns_a_record.automate_lb_dns.zone_name}"
  subject_alternative_names = ["${var.automate_hostname}-fe.${azurerm_dns_a_record.automate_lb_dns.zone_name}"]

  dns_challenge {
    provider = "azure"

    config {
      AZURE_CLIENT_ID       = "${var.azure_client_id}"
      AZURE_CLIENT_SECRET   = "${var.azure_client_secret}"
      AZURE_SUBSCRIPTION_ID = "${var.azure_sub_id}"
      AZURE_TENANT_ID       = "${var.azure_tenant_id}"
      AZURE_RESOURCE_GROUP  = "azure-dns-rg"
    }
  }
}