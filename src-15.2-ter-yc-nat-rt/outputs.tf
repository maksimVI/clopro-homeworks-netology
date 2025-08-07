output "external_ip_address_public_vm" {
  value       = yandex_compute_instance.public-vm.network_interface.0.nat_ip_address
}

output "internal_ip_address_private_vm" {
  value       = yandex_compute_instance.private-vm.network_interface.0.ip_address
}

output "external_ip_address_nat_vm" {
  value       = yandex_compute_instance.nat-vm.network_interface.0.nat_ip_address
}

output "image_url" {
  value       = "http://${yandex_storage_bucket.image-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}

output "network_load_balancer_ip" {
  value       = yandex_lb_network_load_balancer.lamp-nlb.listener.*.external_address_spec[0].*.address
}