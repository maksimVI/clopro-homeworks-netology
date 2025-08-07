# VPC из ДЗ 15.1

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
