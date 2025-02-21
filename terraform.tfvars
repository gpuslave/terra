yandex_provider = {
  zone      = "ru-central1-d"
  folder_id = "b1ggegfk5mo7j1ck1p4o"
  cloud_id  = "b1g1f73gcm5vet9spf42"
}

subnets = {
  external_sub_cidr = "172.16.17.0/28"
  internal_sub_cidr = "172.16.16.0/24"
}

ip_addr = {
  bastion_ext_ip = "51.250.35.119"
  bastion_int_ip = "172.16.16.254"
  vm-1_ip        = "172.16.16.7"
  vm-2_ip        = "172.16.16.8"
}

ssh_keys = {
  bastion_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCOMEPyVRcix6K9ZcJcQ+Lr5ScVG9/o7bLurlOXt2S4jZuXSgrVwmuor6gjNEJy7hLePMH7i6ObBIYmQdXhPvwvqVgRKoycqmYy7IXvHPNpIwGbDKwiDVrWhgif8P8i3ywDDY27FHBYvzRtT54BcFPaBaUG9iX7qK5Rk0zr4veH63WTRGRjHn972SMfA+pg2ArEyAsKvJ+A9oSuXClayqiCA8sCWHKcyg8kqRfEFWsvzN/MQLk6LZspZYCqJ9s+cwsBmYboLIOd2BiNWBpL/I1TLdBOmcO2f6AqrroYBhJxV7xpHCJh7UnQU/F+85GU/ztL8fQoeuYnu4mfIOfIAHt gpuslave@batman.local"
  vm-1_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsbB++OKh5w1RyO53KivYhu1fvj3ZoLgYnuiH8c9bbV gpuslave@batman.local"
  vm-2_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyMo8XdtYja+2M0oxX5k1879XivBNFQMg23qgh5liLb gpuslave@batman.local"
}

images = {
  ubuntu_2404         = "fd8m5hqeuhbtbhltuab4"
  ubuntu_2204_bastion = "fd81vhfcdt7ntmco1qeq"
}

vm_resources = {
  "vm-1" = {
    cores  = 4
    memory = 4
    disk   = 40
  }

  "vm-2" = {
    cores  = 2
    memory = 2
    disk   = 20
  }

  "vm-bastion" = {
    cores  = 2
    memory = 2
    disk   = 20
  }
}


# ---

# vm_instances = {
#   "vm-1" = {
#     name    = "vm-1"
#     cores   = 4
#     memory  = 4
#     disk    = 40
#     image   = "fd8m5hqeuhbtbhltuab4"
#     ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsbB++OKh5w1RyO53KivYhu1fvj3ZoLgYnuiH8c9bbV gpuslave@batman.local"
#   }

#   "vm-2" = {
#     name    = "vm-2"
#     cores   = 2
#     memory  = 2
#     disk    = 20
#     image   = "fd8m5hqeuhbtbhltuab4"
#     ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyMo8XdtYja+2M0oxX5k1879XivBNFQMg23qgh5liLb gpuslave@batman.local"
#   }
# }