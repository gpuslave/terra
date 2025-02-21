output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
}

output "bastion_internal_ip" {
  description = "Internal IP of Bastion Host"
  value       = yandex_compute_instance.vm-bastion.network_interface.1.ip_address
}

output "internal_network_id" {
  description = "ID of Internal Network"
  value       = yandex_vpc_network.internal-bastion-network.id
}

output "external_network_id" {
  description = "ID of External Network"
  value       = yandex_vpc_network.external-bastion-network.id
}