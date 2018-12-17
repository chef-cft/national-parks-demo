resource "aws_instance" "permanent_peer" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.national_parks_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.national_parks.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "permanent_peer_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.permanent_peer.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname np-permanent-peer",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
    ]

  }
}


# Single Mongdb instance peered with the permanent peer
resource "aws_instance" "mongodb" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.national_parks_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.national_parks.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "np_mongodb_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    source     = "files/mongo.toml"
    destination = "/home/${var.aws_ami_user}/mongo.toml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname np-mongodb-${var.prod_channel}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep 15",
      "sudo hab svc load core/mongodb --group ${var.group}",
      "sudo hab config apply mongodb.${var.group} $(date +%s) /home/${var.aws_ami_user}/mongo.toml"
    ]

<<<<<<< HEAD
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20"
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    service {
      name     = "core/mongodb"
      channel  = "stable"
      user_toml = "${file("files/mongo.toml")}"
    }

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
=======
>>>>>>> 480112624d4d1b7db96cbaa81ee1a4679fd5dcac
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "national_parks" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.national_parks_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.national_parks.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true
  count                       = "${var.count}"

  tags {
    Name          = "national_parks_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname national-parks-${var.count}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep 15",
      "sudo hab svc load ${var.origin}/national-parks --group ${var.group} --channel ${var.prod_channel} --strategy ${var.update_strategy} --bind database:mongodb.${var.group}"

<<<<<<< HEAD
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20"
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    service {
      name     = "${var.origin}/national-parks"
      channel  = "${var.prod_channel}"
      strategy = "at-once"
      binds    = ["database:mongodb.default"]
    }

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
=======
    ]
>>>>>>> 480112624d4d1b7db96cbaa81ee1a4679fd5dcac
  }
}

# HAProxy instance peered with permanent peer and binded to the national-parks instance
resource "aws_instance" "haproxy" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.national_parks_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.national_parks.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "haproxy_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.sup_service.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    source     = "files/haproxy.toml"
    destination = "/home/${var.aws_ami_user}/haproxy.toml"
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
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep 15",
      "sudo hab svc load core/haproxy --group ${var.group} --bind backend:national-parks.${var.group}",
      "sudo hab config apply haproxy.${var.group} $(date +%s) /home/${var.aws_ami_user}/haproxy.toml"
    ]
  }
}

////////////////////////////////
// Templates

data "template_file" "permanent_peer" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

<<<<<<< HEAD
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20"
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
  provisioner "habitat" {
    peer         = "${aws_instance.permanent_peer.private_ip}"
    use_sudo     = true
    service_type = "systemd"

    service {
      name     = "core/haproxy"
      channel  = "stable"
      binds    = ["backend:national-parks.default"]
      user_toml = "${file("files/haproxy.toml")}" 
    }

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
=======
  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
>>>>>>> 480112624d4d1b7db96cbaa81ee1a4679fd5dcac
  }
}

data "template_file" "sup_service" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --peer ${aws_instance.permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

data "template_file" "install_hab" {
  template = "${file("${path.module}/../templates/install-hab.sh")}"
}
