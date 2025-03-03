terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  required_version = ">= 0.13"
}

resource "yandex_vpc_network" "external-bastion-network" {
  name = var.network_name
}

resource "yandex_vpc_security_group" "external-bastion-sg" {
  name        = var.sg_name
  description = "bastion-external-sg"
  network_id  = yandex_vpc_network.external-bastion-network.id

  # SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP/HTTPS
  egress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "external-bastion-subnet" {
  name = var.subnet_name
  zone = var.zone
  # zone       = "ru-central1-d"
  network_id = yandex_vpc_network.external-bastion-network.id

  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_compute_disk" "boot-disk-bastion" {
  name = var.boot_disk.name

  type = var.boot_disk.type
  # type     = "network-hdd"
  zone = var.boot_disk.zone
  # zone     = "ru-central1-d"
  size = var.boot_disk.size
  # size     = var.vm_resources["vm-bastion"].disk
  image_id = var.boot_disk.image_id
  # image_id = var.images.ubuntu_2204_bastion
}

resource "yandex_compute_instance" "vm-bastion" {
  name = var.bastion.name
  # name        = "bastion-1"
  zone = var.bastion.zone
  # zone        = "ru-central1-d"
  platform_id = var.bastion.platform_id
  # platform_id = "standard-v2"

  resources {
    cores  = var.bastion.resources.cores
    memory = var.bastion.resources.memory
    # cores  = var.vm_resources["vm-bastion"].cores
    # memory = var.vm_resources["vm-bastion"].memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-bastion.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.external-bastion-subnet.id
    nat                = true
    nat_ip_address     = var.bastion_external_ip
    security_group_ids = [yandex_vpc_security_group.external-bastion-sg.id]
  }

  network_interface {
    subnet_id          = var.internal_network.subnet_id
    ipv4               = true
    ip_address         = var.internal_network.bastion_internal_ip
    security_group_ids = [var.internal_network.sg_id]
  }

  metadata = {
    user-data = "${file("${path.module}/cloud-init/bastion.yaml")}"
  }
}