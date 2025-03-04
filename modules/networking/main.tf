
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  required_version = ">= 0.13"
}

# --- NETWORKS

resource "yandex_vpc_network" "internal-network" {
  name = var.network_name
}

resource "yandex_vpc_security_group" "internal-sg" {
  name        = var.sg_name
  description = "internal-sg"
  network_id  = yandex_vpc_network.internal-network.id

  # TCP/22
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["${var.bastion_internal_ip}/32"]
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

  # HTTP/HTTPS
  egress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "internal-subnet" {
  name = var.subnet_name
  zone = var.zone
  # zone       = "ru-central1-d"

  network_id = yandex_vpc_network.internal-network.id

  route_table_id = yandex_vpc_route_table.rt-gateway.id

  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = var.gateway_name
  # name = "bastion-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt-gateway" {
  name = var.route_table_name
  # name       = "bastion-gateway-routing-table"
  network_id = yandex_vpc_network.internal-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}