terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
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

# --- BOOT DISKS

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = "20"
  image_id = "fd8m5hqeuhbtbhltuab4"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = "20"
  image_id = "fd8m5hqeuhbtbhltuab4"
}

resource "yandex_compute_disk" "boot-disk-bastion-1" {
  name     = "boot-disk-bastion-1"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = "10"
  image_id = "fd81vhfcdt7ntmco1qeq"
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

# --- VM'S

resource "yandex_compute_instance" "vm-1" {
  name        = "terraform-1"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-internal.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    ipv4               = true
    ip_address         = var.ip_addr.vm-1_ip
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_keys.vm-1_key}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name        = "terraform-2"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-internal.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    ipv4               = true
    ip_address         = var.ip_addr.vm-2_ip
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_keys.vm-2_key}"
  }
}

resource "yandex_compute_instance" "vm-bastion" {
  name        = "bastion-1"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 2
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