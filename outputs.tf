# VM-1 Network Details
output "vm1_internal_ip" {
  description = "Internal IP of VM-1"
  value       = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

# VM-2 Network Details 
output "vm2_internal_ip" {
  description = "Internal IP of VM-2"
  value       = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

# Bastion Host Network Details
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