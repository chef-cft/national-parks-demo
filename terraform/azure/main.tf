terraform {
  required_version = "~> 0.11"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.azure_sub_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.tag_name}-${var.application}-rg"
  location = "${var.azure_region}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.tag_name}-${var.application}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.tag_name}-${var.application}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.10.0/24"
}

# Create public IPs

resource "azurerm_public_ip" "permanent-peer-pip" {
  name                         = "${var.tag_name}-${var.application}-permanent-peer-pip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Static"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_public_ip" "mongodb-pip" {
  name                         = "${var.tag_name}-${var.application}-mongodb-pip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Static"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_public_ip" "haproxy-pip" {
  name                         = "${var.tag_name}-${var.application}-haproxy-pip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Static"
  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.tag_name}-${var.application}-pip-${count.index}"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Static"
  count                        = "${var.count}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "sg" {
  name                = "${var.tag_name}-${var.application}-sg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8080"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "9631"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9631"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "9638"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9638"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "27017"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "28017"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "28017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8000"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8085"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8085"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create network interface
resource "azurerm_network_interface" "permanent-peer-nic" {
  name                      = "${var.tag_name}-${var.application}-permanent-peer-nic"
  location                  = "${var.azure_region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "permanent-peer-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.permanent-peer-pip.id}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_network_interface" "mongodb-nic" {
  name                      = "${var.tag_name}-${var.application}-mongodb-nic"
  location                  = "${var.azure_region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "mongodb-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.mongodb-pip.id}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_network_interface" "haproxy-nic" {
  name                      = "${var.tag_name}-${var.application}-haproxy-nic"
  location                  = "${var.azure_region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "haproxy-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.haproxy-pip.id}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}
resource "azurerm_network_interface" "nic" {
  name                      = "${var.tag_name}-${var.application}-nic${count.index}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  count                     = "${var.count}"

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 8
}

//////STORAGE///////
////////////////////

# Create initial peer
resource "azurerm_storage_account" "stor" {
  name                     = "stor${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.azure_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_storage_container" "storcont" {
  name 		              = "vhds"
  resource_group_name 	= "${azurerm_resource_group.rg.name}"
  storage_account_name 	= "${azurerm_storage_account.stor.name}"
  container_access_type = "private"
}

//////INSTANCES///////
//////////////////////
resource "azurerm_virtual_machine" "permanent-peer" {
  name                  = "${var.tag_name}-${var.application}-permanent-peer"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.permanent-peer-nic.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  connection {
    host        = "${azurerm_public_ip.permanent-peer-pip.ip_address}"
    user        = "${var.azure_image_user}"
    password    = "${var.azure_image_password}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-permanent-peer-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-permanent-peer-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "permanent-peer"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.permanent_peer.rendered}"
    destination = "/home/${var.azure_image_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.azure_image_password} | sudo -S yum update -y",
      "sudo groupadd hab",
      "sudo useradd hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.azure_image_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/audit-baseline/config /hab/user/config-baseline/config",
      "sudo chown -R hab:hab /hab/user",
      "sudo cp /home/${var.azure_image_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo hab svc load effortless/audit-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load effortless/config-baseline --channel stable --strategy at-once --group ${var.group}",
    ]

  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create mongodb instance
resource "azurerm_virtual_machine" "mongodb" {
  depends_on            = ["azurerm_network_interface.nic"]
  name                  = "${var.tag_name}-${var.application}-mongodb"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.mongodb-nic.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  connection {
    host        = "${azurerm_public_ip.mongodb-pip.ip_address}"
    user        = "${var.azure_image_user}"
    password    = "${var.azure_image_password}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-mongodb-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-mongodb-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "national-parks-mongodb"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.azure_image_user}/hab-sup.service"
  }

  provisioner "file" {
    source     = "files/mongo.toml"
    destination = "/home/${var.azure_image_user}/mongo.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.azure_image_password} | sudo -S yum update -y",
      "sudo groupadd hab",
      "sudo useradd hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.azure_image_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/mongodb/config /hab/user/audit-baseline/config /hab/user/config-baseline/config",
      "sudo chown -R hab:hab /hab/user",
      "sudo cp /home/${var.azure_image_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/mongo.toml /hab/user/mongodb/config/user.toml",
      "sudo hab svc load effortless/audit-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load effortless/config-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load core/mongodb --group ${var.group}"
    ]
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create web application instance
resource "azurerm_virtual_machine" "app" {
  depends_on            = ["azurerm_network_interface.nic"]
  name                  = "${var.tag_name}-${var.application}-app${count.index}"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  count                 = "${var.count}"

  connection {
    host        = "${element(azurerm_public_ip.pip.*.ip_address, count.index)}"
    user        = "${var.azure_image_user}"
    password    = "${var.azure_image_password}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-app${count.index}-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-app-osdisk${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "national-parks-${count.index}"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }
  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.azure_image_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.azure_image_password} | sudo -S yum update -y",
      "sudo groupadd hab",
      "sudo useradd hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.azure_image_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/audit-baseline/config /hab/user/config-baseline/config",
      "sudo chown -R hab:hab /hab/user",
      "sudo cp /home/${var.azure_image_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo hab svc load effortless/audit-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load effortless/config-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load ${var.origin}/national-parks --group ${var.group} --channel ${var.channel} --strategy ${var.update_strategy} --bind database:mongodb.${var.group}"
    ]
  }


  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create HAProxy instance
resource "azurerm_virtual_machine" "haproxy" {
  depends_on            = ["azurerm_network_interface.nic"]
  #depends_on            = ["azurerm_virtual_machine.app"]
  name                  = "${var.tag_name}-${var.application}-haproxy"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.haproxy-nic.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  connection {
    host        = "${azurerm_public_ip.haproxy-pip.ip_address}"
    user        = "${var.azure_image_user}"
    password    = "${var.azure_image_password}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-haproxy-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-haproxy-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "haproxy-national-parks"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.azure_image_user}/hab-sup.service"
  }

  provisioner "file" {
    source     = "files/haproxy.toml"
    destination = "/home/${var.azure_image_user}/haproxy.toml"
  }
  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.azure_image_user}/config_linux.toml"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${var.azure_image_password} | sudo -S yum update -y",
      "sudo groupadd hab",
      "sudo useradd hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.azure_image_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/audit-baseline/config /hab/user/config-baseline/config",
      "sudo chown -R hab:hab /hab/user",
      "sudo cp /home/${var.azure_image_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo cp /home/${var.azure_image_user}/haproxy.toml /hab/user/haproxy/config/user.toml",
      "sudo hab svc load effortless/audit-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load effortless/config-baseline --channel stable --strategy at-once --group ${var.group}",
      "sudo hab svc load core/haproxy --group ${var.group} --bind backend:national-parks.${var.group}"
    ]
  }
  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}
