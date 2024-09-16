resource "aws_instance" "permanent_peer" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.rhel7.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.national_parks_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true

  tags = {
    Name          = "permanent_peer_${random_id.instance_id.hex}"
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
    content     = data.template_file.permanent_peer.rendered
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
      "sudo hostname permanent-peer",
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
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
    ]
  }
}

# Single Mongdb instance peered with the permanent peer
resource "aws_instance" "mongodb" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.rhel7.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.national_parks_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = "40"
  }

  tags = {
    Name          = "np_mongodb_${random_id.instance_id.hex}"
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
    source      = "files/mongo.toml"
    destination = "/home/${var.aws_ami_user}/mongo.toml"
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
      "sudo hostname mongodb-national-parks-${var.prod_channel}",
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
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/mongodb/config /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/mongo.toml /hab/user/mongodb/config/user.toml",
      "sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load core/mongodb/3.2.10/20171016003652 --group ${var.group}",
    ]
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "national_parks" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.rhel7.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.national_parks_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true
  count                       = var.node_count

  tags = {
    Name          = "national_parks_${random_id.instance_id.hex}"
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
      "sudo hostname national-parks-${var.node_count}",
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
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load ${var.origin}/national-parks --group ${var.group} --channel ${var.prod_channel} --strategy ${var.update_strategy} --update-condition ${var.update_condition} --bind database:mongodb.${var.group}",
    ]
  }
}

# HAProxy instance peered with permanent peer and binded to the national-parks instance
resource "aws_instance" "haproxy" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.rhel7.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.national_parks_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true

  tags = {
    Name          = "haproxy_${random_id.instance_id.hex}"
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
    source      = "files/haproxy.toml"
    destination = "/home/${var.aws_ami_user}/haproxy.toml"
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
      "sudo hostname haproxy-national-parks",
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
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/haproxy.toml /hab/user/haproxy/config/user.toml",
      "sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load core/haproxy --group ${var.group} --bind backend:national-parks.${var.group}",
    ]
  }
}

