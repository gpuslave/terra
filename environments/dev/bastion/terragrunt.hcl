
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/bastion"
}

dependency "networking" {
  config_path = "../networking"
}

inputs = {
  network_name = "bastion-external-network"
  sg_name      = "bastion-extenral-sg"
  subnet_name  = "bastion-external-subnet"

  zone = include.root.inputs.yandex_provider.zone

  subnet_cidr         = include.root.inputs.subnets.external_sub_cidr
  bastion_external_ip = include.root.inputs.ip_addr.bastion_ext_ip

  boot_disk = {
    image_id = include.root.inputs.images.ubuntu_2204_bastion
    name     = "bastion-boot"
    zone     = include.root.inputs.yandex_provider.zone
    size     = 64
    type     = "network-hdd"
  }

  bastion = {
    name        = "bastion-1"
    zone        = include.root.inputs.yandex_provider.zone
    platform_id = "standard-v2"
    resources = {
      cores  = 2
      memory = 4
    }
  }

  internal_network = {
    subnet_id           = dependency.networking.outputs.subnet_id
    bastion_internal_ip = include.root.inputs.ip_addr.bastion_int_ip
    sg_id               = dependency.networking.outputs.sg_id
  }
}