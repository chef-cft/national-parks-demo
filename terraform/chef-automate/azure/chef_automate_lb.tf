resource "azurerm_public_ip" "automate_lb_pip" {
  name                = "chef-automate-lb-${random_id.instance_id.hex}-pip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_dns_a_record" "automate_lb_dns" {
  name                = "${var.automate_hostname}"
  zone_name           = "${var.automate_app_gateway_dns_zone}"
  resource_group_name = "azure-dns-rg"
  ttl                 = 300
  records             = ["${azurerm_public_ip.automate_lb_pip.ip_address}"]
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.automate_hostname}-avset" // same as above
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  #managed                      = true
}

resource "azurerm_lb" "automate_lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${azurerm_resource_group.rg.name}-lb"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "AutomateLBFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.automate_lb_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.automate_lb.id}"
  name                = "BackendPool"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.automate_lb.id}"
  name                           = "HTTPS-Rule"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "AutomateLBFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
}
