output "network_id" {
  value = yandex_vpc_network.internal-network.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.internal-subnet.id
}

output "sg_id" {
  value = yandex_vpc_security_group.internal-sg.id
}