output "permanent_peer_public_ip" {
  value = "${aws_instance.permanent_peer.public_ip}"
}

output "mongodb_public_ip" {
  value = "${aws_instance.mongodb.public_ip}"
}

output "national_parks_public_ip" {
  value = "${join(",", aws_instance.national_parks.*.public_ip)}"
}

output "haproxy_public_ip" {
  value = "${aws_instance.haproxy.public_ip}"
}
