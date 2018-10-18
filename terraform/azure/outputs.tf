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