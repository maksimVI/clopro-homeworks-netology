// https://yandex.cloud/en/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.5"
}

provider "yandex" {
  # token     = var.yc_token
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.default_zone
  
  service_account_key_file = file("./authorized_key.json")
}
