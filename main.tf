terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "my-new-bucket-gpuslave"
    region = "ru-central1"
    key    = "states/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
    skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
  }

  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = var.yandex_provider.zone
  folder_id = var.yandex_provider.folder_id
  cloud_id  = var.yandex_provider.cloud_id
}

# --- NETWORKS

resource "yandex_vpc_network" "internal-bastion-network" {
  name = "internal-bastion-network"
}

resource "yandex_vpc_network" "external-bastion-network" {
  name = "external-bastion-network"
}

# --- SECURITY GROUPS

resource "yandex_vpc_security_group" "secure-bastion-sg" {
  name        = "bastion-sec-group"
  description = "bastion"
  network_id  = yandex_vpc_network.external-bastion-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name        = "bastion-internal-group"
  description = "bastion"
  network_id  = yandex_vpc_network.internal-bastion-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["${var.ip_addr.bastion_int_ip}/32"]
  }

  egress {
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# --- SUBNETS

resource "yandex_vpc_subnet" "bastion-subnet-internal" {
  name       = "bastion-internal-segment"
  zone       = "ru-central1-d"
  network_id = yandex_vpc_network.internal-bastion-network.id

  v4_cidr_blocks = [var.subnets.internal_sub_cidr]
}

resource "yandex_vpc_subnet" "bastion-subnet-external" {
  name       = "bastion-external-segment"
  zone       = "ru-central1-d"
  network_id = yandex_vpc_network.external-bastion-network.id

  v4_cidr_blocks = [var.subnets.external_sub_cidr]
}

# TODO: configure images as resources
# resource "yandex_compute_image" "ubuntu_2004" {
#   source_family = "ubuntu-2004-lts"
# }

# --- BASTION

resource "yandex_compute_disk" "boot-disk-bastion-1" {
  name     = "boot-disk-bastion-1"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = var.vm_resources["vm-bastion"].disk
  image_id = var.images.ubuntu_2204_bastion
}

resource "yandex_compute_instance" "vm-bastion" {
  name        = "bastion-1"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = var.vm_resources["vm-bastion"].cores
    memory = var.vm_resources["vm-bastion"].memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-bastion-1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-external.id
    index              = 1
    nat                = true
    nat_ip_address     = var.ip_addr.bastion_ext_ip
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-internal.id
    index              = 2
    ipv4               = true
    ip_address         = var.ip_addr.bastion_int_ip
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
  }

  metadata = {
    user-data = "${file("./cloud-init/bastion.yaml")}"
  }
}

module "vm-cattle" {
  source = "./modules/services/vm-cattle"

  vm_instances = {
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

  vm_ips = {
    vm-1_ip = var.ip_addr.vm-1_ip
    vm-2_ip = var.ip_addr.vm-2_ip
  }

  yandex_provider = var.yandex_provider

  sg_id     = yandex_vpc_security_group.internal-bastion-sg.id
  subnet_id = yandex_vpc_subnet.bastion-subnet-internal.id

}