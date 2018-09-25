output "aws_linux_acceptance_public_ip" {
  value = "${aws_instance.aws-linux-acceptance.public_ip}"
}

output "aws_linux_production_public_ip" {
  value = "${aws_instance.aws-amazon-linux-production.public_ip}"
}
