variable "do_token" {}

variable "root_dir" {
  default = "/home/lukas/blog"
}

variable "pub_key" {
  default = "/home/lukas/.ssh/id_rsa_passwordless.pub"
}
variable "pvt_key" {
  default = "/home/lukas/.ssh/id_rsa_passwordless"
}
variable "ssh_fingerprint" {
  default = "26:ee:c4:a0:28:16:dd:51:9c:a4:bc:ae:fc:fa:d7:c9"
}

provider "digitalocean" {
  token = "${var.do_token}"
}
