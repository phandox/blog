resource "digitalocean_droplet" "dev-docker-host" {
  count = 1
  image = "${var.do_droplet_image}"
  name = "dev-docker-host-${count.index}"
  region = "${var.do_region}" # Frankfurt 1 Region
  size = "${var.do_droplet_size}", # 1 CPU, 1GB RAM, 25 GB HDD
  ssh_keys = [
      "${var.ssh_fingerprint}"
  ]

  connection = {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
}
