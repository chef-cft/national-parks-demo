output "dca_public_ips" {
  value = join(",",aws_instance.dca.*.public_ip)
}
