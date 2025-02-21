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
}

variable "vm_ips" {
  type = object({
    vm-1_ip        = string
    vm-2_ip        = string
  })
  description = "All of the IP's Used In this Configuration"
}

variable "yandex_provider" {
  type = object({
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "Yandex Cloud Computing Zone"
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = string 
}