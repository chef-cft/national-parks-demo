# output "initial-peer_public_ip" {
#   value = "${azurerm_public_ip.pip.0.ip_address}"
# }

# output "mongodb_public_ip" {
#   value = "${azurerm_public_ip.pip.1.ip_address}"
# }

# output "national-parks_public_ip" {
#   value = "${azurerm_public_ip.pip.2.ip_address}"
# }

# output "haproxy_public_ip" {
#   value = "${azurerm_public_ip.pip.3.ip_address}"
# }

output "permanent-peer_public_ip" {
  value = "${data.azurerm_public_ip.permanent-peer.ip_address}"
}

output "mongodb_public_ip" {
  value = "${data.azurerm_public_ip.mongodb.ip_address}"
}

output "national-parks_public_ip" {
  value = "${data.azurerm_public_ip.national-parks.ip_address}"
}

output "haproxy_public_ip" {
  value = "${data.azurerm_public_ip.haproxy.ip_address}"
}