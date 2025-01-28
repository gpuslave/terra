resource "yandex_compute_disk" "boot-disk" {
  for_each = var.vm_instances

  name     = "boot-disk-${each.key}"
  type     = "network-hdd"
  zone     = var.yandex_provider.zone
  size     = each.value.disk
  image_id = each.value.image
}

resource "yandex_compute_instance" "vm" {
  for_each    = var.vm_instances
  name        = each.value.name
  zone        = var.yandex_provider.zone
  platform_id = "standard-v2"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id
    # disk_id = yandex_compute_disk.boot-disk["boot-disk-${each.key}"].id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-subnet-internal.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    ipv4               = true
    ip_address         = var.ip_addr["${each.key}_ip"]
  }

  metadata = {
    ssh-keys = "ubuntu:${each.value.ssh_key}"
  }
}