variable "network_name" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "bastion_internal_ip" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "bastion_external_ip" {
  type = string
}

variable "boot_disk" {
  type = object({
    name     = string
    zone     = string
    size     = number
    image_id = string
  })
}

variable "bastion" {
  type = object({
    name        = string
    zone        = string
    platform_id = string
    resources = object({
      cores  = number
      memory = number
    })
  })
}

variable "internal_network" {
  type = object({
    subnet_id           = string
    bastion_internal_ip = string
    sg_id               = string
  })
}

