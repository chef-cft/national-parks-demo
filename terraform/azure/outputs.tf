
output "haproxy-public-ip" {
  value = "${azurerm_public_ip.haproxy-pip.ip_address}"
}

output "mongodb-public-ip" {
  value = "${azurerm_public_ip.mongodb-pip.ip_address}"
}

output "permanent-peer-public-ip" {
  value = "${azurerm_public_ip.permanent-peer-pip.ip_address}"
}

output "instance_ips" {
  value = ["${azurerm_public_ip.pip.*.ip_address}"]
}