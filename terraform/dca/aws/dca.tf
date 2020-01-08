# Launch var.node_count CentOS instances for DCA Demos
resource "aws_instance" "dca" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.centos.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.dca_subnet.id
  vpc_security_group_ids      = [aws_security_group.dca.id]
  associate_public_ip_address = true
  count                       = var.node_count

  tags = {
    Name          = "dca_${random_id.instance_id.hex}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }

  provisioner "file" {
    content     = data.template_file.install_hab.rendered
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = data.template_file.sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname dca-${var.node_count}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo mkdir -p /hab/user/${var.infra_package}/config /hab/user/${var.audit_package}/config",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/${var.audit_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.infra_package}/config/user.toml",
      "sudo hab pkg install ${var.infra_origin}/${var.infra_package} --channel stable",
      "sudo hab pkg install ${var.audit_origin}/${var.audit_package} --channel stable",
    ]
  }
}
