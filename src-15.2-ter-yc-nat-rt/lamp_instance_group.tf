# Service account for VM group
resource "yandex_iam_service_account" "sa-lamp-group" {
  name = "sa-lamp-group"
  description = "Service account for managing VM group"
}

# Add role editor for service account
resource "yandex_resourcemanager_folder_iam_member" "sa-lamp-group-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-lamp-group.id}"
}

// https://terraform-provider.yandexcloud.net/resources/compute_instance_group
resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-instance-group"
  service_account_id = yandex_iam_service_account.sa-lamp-group.id
  
  instance_template {
    platform_id = var.vms_resources.public.platform_id # используем те же параметры, что и для public-vm

    resources {
      cores         = var.vms_resources.public.cores
      memory        = var.vms_resources.public.memory
      core_fraction = var.vms_resources.public.core_fraction
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" # готовый образ с LAMP
        size     = 10
      }
    }

    scheduling_policy {
      preemptible = true  # режим прерываемой ВМ, стоит дешевле
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      serial-port-enable = var.vms_metadata.ssh.serial_port_enable
      ssh-keys           = var.vms_metadata.ssh.keys
      # создаем веб-страницу с картинкой из бакета
      user-data = <<-EOT
        #!/bin/bash
        sudo echo '<html><body><img src="http://${yandex_storage_bucket.image-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"></body></html>' > /var/www/html/index.html
      EOT
    }
  }

  scale_policy {
    fixed_scale {
      size = 3 # размер группы из 3 ВМ
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  // проверкa состояния ВМ
  // https://terraform-provider.yandexcloud.net/resources/compute_instance_group.html#nested-schema-for25
  health_check {
    interval = 15
    timeout = 5
    unhealthy_threshold = 3   # считать инстанс нездоровым после 3 проверок
    healthy_threshold = 2     # считать инстанс здоровым после 2 проверок

    # проверка по HTTP
    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name        = "lamp-tg"
    target_group_description = "Целевая группа для LAMP инстансов"
  }

}