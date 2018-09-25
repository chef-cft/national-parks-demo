resource "aws_instance" "aws-linux-acceptance" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.base_linux.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "aws_amazon_acceptance_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    source      = "files/chef-base.toml"
    destination = "/tmp/chef-base.toml"
  }

  provisioner "file" {
    source      = "files/compliance.toml"
    destination = "/tmp/compliance.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname aws-linux-${var.dev_channel}",
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    use_sudo     = true
    service_type = "systemd"

    service {
      name     = "scottford/chef-base"
      channel  = "${var.dev_channel}"
      strategy = "at-once"
    }

    service {
      name     = "scottford/compliance"
      channel  = "${var.dev_channel}"
      strategy = "at-once"
    }

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}

resource "aws_instance" "aws-amazon-linux-production" {
  connection {
    user        = "${var.aws_centos_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.base_linux.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "aws_amazon_linux_production_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    source      = "files/chef-base.toml"
    destination = "/tmp/chef-base.toml"
  }

  provisioner "file" {
    source      = "files/compliance.toml"
    destination = "/tmp/compliance.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname aws-linux-${var.prod_channel}",
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }

  provisioner "habitat" {
    use_sudo     = true
    service_type = "systemd"

    service {
      name     = "scottford/chef-base"
      channel  = "${var.prod_channel}"
      strategy = "at-once"
    }

    service {
      name     = "scottford/compliance"
      channel  = "${var.prod_channel}"
      strategy = "at-once"
    }

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.aws_centos_image_user}"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}
