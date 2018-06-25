resource "digitalocean_domain" "luknagy_domain" {
    name = "luknagy.com"
    ip_address = "${digitalocean_droplet.docker-host-1.ipv4_address}"
}

resource "digitalocean_record" "CNAME-blog" {
    domain = "${digitalocean_domain.luknagy_domain.name}"
    type = "CNAME"
    name = "blog"
    value = "luknagy.com."
}

