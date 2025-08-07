# NAT из ДЗ 15.1

resource "yandex_compute_instance" "nat-vm" {
  name        = "nat-vm"
  hostname    = "nat-vm"
  platform_id = var.vms_resources.nat.platform_id
  zone        = var.default_zone

  resources {
    cores  = var.vms_resources.nat.cores
    memory = var.vms_resources.nat.memory
    core_fraction = var.vms_resources.nat.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = var.vms_resources.nat.disk_size
    }
  }

  scheduling_policy {
    preemptible = true  # режим прерываемой ВМ, стоит дешевле
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    serial-port-enable = var.vms_metadata.ssh.serial_port_enable
    ssh-keys           = var.vms_metadata.ssh.keys
  }
}
