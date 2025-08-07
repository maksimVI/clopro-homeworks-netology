# VMs из ДЗ 15.1

# виртуалка с публичным IP

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "public-vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = var.vms_resources.public.platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources.public.cores
    memory        = var.vms_resources.public.memory
    core_fraction = var.vms_resources.public.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id  = data.yandex_compute_image.ubuntu.id
      size      = var.vms_resources.public.disk_size
    }
  }

  scheduling_policy {
    preemptible = true  # режим прерываемой ВМ, стоит дешевле
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    serial-port-enable = var.vms_metadata.ssh.serial_port_enable
    ssh-keys           = var.vms_metadata.ssh.keys
  }
}

# виртуалка с внутренним IP (без публичного)

resource "yandex_compute_instance" "private-vm" {
  name          = "private-vm"
  hostname      = "private-vm"
  platform_id   = var.vms_resources.private.platform_id
  zone          = var.default_zone

  resources {
    cores  = var.vms_resources.private.cores
    memory = var.vms_resources.private.memory
    core_fraction = var.vms_resources.private.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vms_resources.private.disk_size
    }
  }

  scheduling_policy {
    preemptible = true  # режим прерываемой ВМ, стоит дешевле
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false   # без публичного
  }

  metadata = {
    serial-port-enable = var.vms_metadata.ssh.serial_port_enable
    ssh-keys           = var.vms_metadata.ssh.keys
  }
}
