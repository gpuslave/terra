include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/networking"
}

inputs = {

  network_name     = "bastion-internal-network"
  sg_name          = "bastion-internal-sg"
  subnet_name      = "bastion-internal-subnet"
  gateway_name     = "bastion-gateway"
  route_table_name = "bastion-route-table"

  zone                = include.root.inputs.yandex_provider.zone
  bastion_internal_ip = include.root.inputs.ip_addr.bastion_int_ip
  subnet_cidr         = include.root.inputs.subnets.internal_sub_cidr
}