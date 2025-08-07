//
// Create a new Network Load Balancer (NLB).
// https://terraform-provider.yandexcloud.net/resources/lb_network_load_balancer.html
resource "yandex_lb_network_load_balancer" "lamp-nlb" {
  name = "lamp-network-load-balancer"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-group.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
