output "chef_automate_public_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}

output "chef_automate_server_public_r53_dns" {
  value = "${var.automate_hostname}"
}

output "a2_admin" {
  value = "${data.external.a2_secrets.result["a2_admin"]}"
}

output "a2_admin_password" {
  value = "${data.external.a2_secrets.result["a2_password"]}"
}

output "a2_token" {
  value = "${data.external.a2_secrets.result["a2_token"]}"
}

output "a2_url" {
  value = "${data.external.a2_secrets.result["a2_url"]}"
}
