terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  required_version = ">= 0.13"
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = var.gateway_name
  # name = "bastion-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt-gateway" {
  name = var.route_table_name
  # name       = "bastion-gateway-routing-table"
  network_id = var.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}