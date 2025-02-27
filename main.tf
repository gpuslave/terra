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

resource "yandex_vpc_security_group" "external-bastion-sg" {
  name        = "external-bastion-security-group"
  description = "bastion-ext-sg"
  network_id  = yandex_vpc_network.external-bastion-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   protocol = "TCP"
  #   port = 443
  # }

  egress {
    protocol = "TCP"
    port     = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "TCP"
    port     = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name        = "internal-bastion-security-group"
  description = "bastion-int-sg"
  network_id  = yandex_vpc_network.internal-bastion-network.id

  # TCP/22
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["${var.ip_addr.bastion_int_ip}/32"]
  }

  egress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "TCP"
    port     = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "TCP"
    port     = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- GATEWAY
resource "yandex_vpc_gateway" "bastion-nat-gateway" {
  name = "bastion-gateway"
  shared_egress_gateway {}
}

# --- ROUTING
resource "yandex_vpc_route_table" "gateway-rt" {
  name       = "bastion-gateway-routing-table"
  network_id = yandex_vpc_network.internal-bastion-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.bastion-nat-gateway.id
  }
}

# --- SUBNETS

resource "yandex_vpc_subnet" "bastion-subnet-internal" {
  name       = "bastion-internal-segment"
  zone       = "ru-central1-d"
  network_id = yandex_vpc_network.internal-bastion-network.id

  route_table_id = yandex_vpc_route_table.gateway-rt.id

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
    security_group_ids = [yandex_vpc_security_group.external-bastion-sg.id]
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
  source = "./modules/vm-cattle"

  vm_instances = var.vm_instances

  vm_ips = {
    vm-1_ip = var.ip_addr.vm-1_ip
    vm-2_ip = var.ip_addr.vm-2_ip
  }

  yandex_provider = var.yandex_provider

  sg_id     = yandex_vpc_security_group.internal-bastion-sg.id
  subnet_id = yandex_vpc_subnet.bastion-subnet-internal.id
}

