resource "aws_instance" "permanent_peer" {
  connection {
    user        = "${var.aws_centos_image_user}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname np-permanent-peer",
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    permanent_peer = true
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}


# Single Mongdb instance peered with the permanent peer
resource "aws_instance" "mongodb" {
  connection {
    user        = "${var.aws_centos_image_user}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname np-mongodb-${var.prod_channel}",
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
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "national_parks" {
  connection {
    user        = "${var.aws_centos_image_user}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname national-parks-${var.count}",
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
  }
}

# HAProxy instance peered with permanent peer and binded to the national-parks instance
resource "aws_instance" "haproxy" {
  connection {
    user        = "${var.aws_centos_image_user}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname haproxy-national-parks",
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
  }
}
