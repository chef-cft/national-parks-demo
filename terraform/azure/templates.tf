////////////////////////////////
// Templates

data "template_file" "permanent_peer" {
  template = file("${path.module}/../templates/peer-sup.service")

  # Template vars are conditionally set via the `event-stream-enabled` variable.
  # If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer --event-stream-application=${var.event-stream-application} --event-stream-environment=${var.event-stream-environment} --event-stream-site=${var.azure_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
  }
}

data "template_file" "sup_service" {
  template = file("${path.module}/../templates/hab-sup.service")

  # Template vars are conditionally set via the `event-stream-enabled` variable.
  # If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --peer ${azurerm_public_ip.permanent-peer-pip.ip_address} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --event-stream-application=${var.event-stream-application} --event-stream-environment=${var.event-stream-environment} --event-stream-site=${var.azure_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --peer ${azurerm_public_ip.permanent-peer-pip.ip_address} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

data "template_file" "install_hab" {
  template = file("${path.module}/../templates/install-hab.sh")
  vars = {
    opts = var.hab_install_opts
  }
}

data "template_file" "audit_toml_linux" {
  template = file("${path.module}/../templates/audit_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
  }
}

data "template_file" "config_toml_linux" {
  template = file("${path.module}/../templates/config_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
  }
}

