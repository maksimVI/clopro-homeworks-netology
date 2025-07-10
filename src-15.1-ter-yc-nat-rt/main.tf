# VPC

resource "yandex_vpc_network" "lab-net" {
  name = "lab-network"
}
## [Создать подсеть](https://yandex.cloud/ru/docs/vpc/operations/subnet-create)
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lab-net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lab-net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.lab-route-table.id
}
## [Создать статический маршрут](https://yandex.cloud/ru/docs/vpc/operations/static-route-create#tf_1)
resource "yandex_vpc_route_table" "lab-route-table" {
  name = "lab-route-table"
  network_id = yandex_vpc_network.lab-net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-vm.network_interface.0.ip_address
  }
}

# VM

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