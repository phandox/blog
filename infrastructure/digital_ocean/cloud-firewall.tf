# resource "digitalocean_firewall" "docker-host-firewall-rules" {
#     name = "allow-web-ssh"

#     droplet_ids = ["${digitalocean_droplet.docker-host-1.id}"]

#     inbound_rule = [
#         {
#             # Allow SSH 
#             protocol = "tcp" 
#             port_range = "22"
#             source_addresses = ["0.0.0.0/0"]
#         },
#         {
#             # Allow HTTP
#             protocol = "tcp",
#             port_range = "80",
#             source_addresses = ["0.0.0.0/0"]
#         },
#         {
#             # Allow HTTPS
#             protocol = "tcp",
#             port_range = "443",
#             source_addresses = ["0.0.0.0/0"]
#         },
#         {
#             # Allow pinging
#             protocol = "icmp",
#             source_addresses = ["0.0.0.0/0"]
#         }
#     ]

#     outbound_rule = [
#         {
#             protocol = "tcp",
#             destination_addresses = ["0.0.0.0//0"]
#         },
#         {
#             protocol = "udp",
#             destination_addresses = ["0.0.0.0//0"]
#         },
#         {
#             protocol = "icmp",
#             destination_addresses = ["0.0.0.0//0"]
#         }
#     ]
# }
