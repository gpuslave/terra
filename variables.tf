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
}

variable "ssh_keys" {
  type = object({
    vm-1_key    = string
    vm-2_key    = string
    bastion_key = string
  })
  description = "SSH Keys"
}

variable "subnets" {
  type = object({
    internal_sub_cidr = string
    external_sub_cidr = string
  })
  description = "CIDR's for subnets"
}

variable "images" {
  type = object({
    ubuntu_2404         = string
    ubuntu_2204_bastion = string
  })
  description = "Image id's for VM instances"
}

variable "vm_resources" {
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  description = "CPU, mem, disk settings for each VM instance"
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
