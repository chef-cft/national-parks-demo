////////////////////////////////
// Templates

data "template_file" "permanent_peer" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
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

data "template_file" "audit_toml_linux" {
  template = "${file("${path.module}/../templates/audit_linux.toml")}"

  vars {
    automate_url = "${var.automate_url}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}

data "template_file" "config_toml_linux" {
  template = "${file("${path.module}/../templates/config_linux.toml")}"

  vars {
    automate_url = "${var.automate_url}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}