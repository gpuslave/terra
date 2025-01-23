terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = "ru-central1-d"
  folder_id = "b1ggegfk5mo7j1ck1p4o"
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

  # egress {
  #   protocol = "ANY"
  #   v4_cidr_blocks = ["192.168.10.0/24"]
  # }
}

resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name        = "bastion-internal-group"
  description = "bastion"
  network_id  = yandex_vpc_network.internal-bastion-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["172.16.16.254/32"]
  }

  egress {
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # egress {
  #   protocol = "ANY"
  #   v4_cidr_blocks = ["192.168.10.0/24"]
  # }
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

  # todo
  v4_cidr_blocks = ["172.16.16.0/24"]
}

resource "yandex_vpc_subnet" "bastion-subnet-external" {
  name       = "bastion-external-segment"
  zone       = "ru-central1-d"
  network_id = yandex_vpc_network.external-bastion-network.id

  # todo
  v4_cidr_blocks = ["172.16.17.0/28"]
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
    ip_address         = "172.16.16.7"
    # nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/VM_1_KEY.pub")}"
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
    # nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/VM_2_KEY.pub")}"
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
    nat_ip_address     = "51.250.35.119"
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-internal.id
    index              = 2
    ipv4               = true
    ip_address         = "172.16.16.254"
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
  }

  metadata = {
    # ssh-keys  = "ubuntu:${file("~/.ssh/BASTION_KEY.pub")}"
    user-data = "${file("./cloud-init/bastion.yaml")}"
  }
}

# --- OUTPUTS

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

# output "external_ip_adress_vm_1" {
#   value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
# }

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

# output "external_ip_adress_vm_2" {
#   value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
# }