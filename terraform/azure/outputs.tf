output "instance_ips" {
  value = ["${azurerm_public_ip.pip.*.ip_address}"]
}

# output "national-parks-public-ip" {
#   value = "${azurerm_public_ip.pip.2.ip_address}"
# }
# output "haproxy-public-ip" {
#   value = "${azurerm_public_ip.pip.3.ip_address}"
# }

output "national-parks-public-ip" {
  value = "${data.azurerm_public_ip.app.ip_address}"
}

output "haproxy-public-ip" {
  value = "${data.azurerm_public_ip.haproxy.ip_address}"
}