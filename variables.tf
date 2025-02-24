variable "yandex_provider" {
  type = object({
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "Yandex Cloud Computing Zone"
}

variable "ip_addr" {
  type = object({
    vm-1_ip        = string
    vm-2_ip        = string
    bastion_ext_ip = string
    bastion_int_ip = string
  })
  description = "All of the IP's Used In this Configuration"

  default = {
    bastion_ext_ip = "51.250.35.119"
    bastion_int_ip = "172.16.16.254"
    vm-1_ip        = "172.16.16.7"
    vm-2_ip        = "172.16.16.8"
  }
}

variable "ssh_keys" {
  type = object({
    vm-1_key    = string
    vm-2_key    = string
    bastion_key = string
  })
  description = "SSH Keys"

  default = {
    bastion_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCOMEPyVRcix6K9ZcJcQ+Lr5ScVG9/o7bLurlOXt2S4jZuXSgrVwmuor6gjNEJy7hLePMH7i6ObBIYmQdXhPvwvqVgRKoycqmYy7IXvHPNpIwGbDKwiDVrWhgif8P8i3ywDDY27FHBYvzRtT54BcFPaBaUG9iX7qK5Rk0zr4veH63WTRGRjHn972SMfA+pg2ArEyAsKvJ+A9oSuXClayqiCA8sCWHKcyg8kqRfEFWsvzN/MQLk6LZspZYCqJ9s+cwsBmYboLIOd2BiNWBpL/I1TLdBOmcO2f6AqrroYBhJxV7xpHCJh7UnQU/F+85GU/ztL8fQoeuYnu4mfIOfIAHt gpuslave@batman.local"
    vm-1_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsbB++OKh5w1RyO53KivYhu1fvj3ZoLgYnuiH8c9bbV gpuslave@batman.local"
    vm-2_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyMo8XdtYja+2M0oxX5k1879XivBNFQMg23qgh5liLb gpuslave@batman.local"
  }
}

variable "subnets" {
  type = object({
    internal_sub_cidr = string
    external_sub_cidr = string
  })
  description = "CIDR's for subnets"

  default = {
    external_sub_cidr = "172.16.17.0/28"
    internal_sub_cidr = "172.16.16.0/24"
  }
}

variable "images" {
  type = object({
    ubuntu_2404         = string
    ubuntu_2204_bastion = string
  })
  description = "Image id's for VM instances"

  default = {
    ubuntu_2404         = "fd8m5hqeuhbtbhltuab4"
    ubuntu_2204_bastion = "fd81vhfcdt7ntmco1qeq"
  }
}

variable "vm_resources" {
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  description = "CPU, mem, disk settings for each VM instance"

  default = {
    # NO LONGER NEEDED
    # "vm-1" = {
    #   cores  = 4
    #   memory = 4
    #   disk   = 40
    # }

    # "vm-2" = {
    #   cores  = 2
    #   memory = 2
    #   disk   = 20
    # }

    "vm-bastion" = {
      cores  = 2
      memory = 2
      disk   = 20
    }
  }
}

variable "vm_instances" {
  type = map(object({
    name    = string
    cores   = number
    memory  = number
    disk    = number
    image   = string
    ssh_key = string
  }))

  description = "value"

  default = {
    "vm-1" = {
      name    = "vm-1"
      cores   = 4
      memory  = 4
      disk    = 40
      image   = "fd8m5hqeuhbtbhltuab4"
      ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsbB++OKh5w1RyO53KivYhu1fvj3ZoLgYnuiH8c9bbV gpuslave@batman.local"
    }

    "vm-2" = {
      name    = "vm-2"
      cores   = 2
      memory  = 2
      disk    = 20
      image   = "fd8m5hqeuhbtbhltuab4"
      ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyMo8XdtYja+2M0oxX5k1879XivBNFQMg23qgh5liLb gpuslave@batman.local"
    }
  }
}
