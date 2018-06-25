resource "digitalocean_droplet" "docker-host-1" {
  image = "centos-7-x64"
  name = "docker-host-1"
  region = "fra1" # Frankfurt 1 Region
  size = "s-1vcpu-1gb", # 1 CPU, 1GB RAM, 25 GB HDD
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
