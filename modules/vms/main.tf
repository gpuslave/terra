terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }
}

# --- BOOT DISK

resource "yandex_compute_disk" "boot-disk" {
  for_each = var.vm_instances

  name     = "boot-disk-${each.key}"
  type     = "network-hdd"
  zone     = var.yandex_provider.zone
  size     = each.value.disk
  image_id = each.value.image
}

# --- VM

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
  }

  network_interface {
    subnet_id          = var.subnet_id
    security_group_ids = [var.sg_id]
    ipv4               = true
    ip_address         = var.vm_ips["${each.key}_ip"]
  }

  metadata = {
    ssh-keys = "ubuntu:${each.value.ssh_key}"
  }
}