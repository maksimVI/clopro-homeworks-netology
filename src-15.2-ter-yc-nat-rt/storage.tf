# ДЗ 15.2 - Создать бакет Object Storage и разместить в нём файл с картинкой

# https://terraform-provider.yandexcloud.net/resources/storage_bucket

// Create SA bucket
resource "yandex_iam_service_account" "sa-bucket" {
  name      = "sa-bucket"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-bucket-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key-bucket" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
// [Настройка публичного доступа к бакету](https://yandex.cloud/ru/docs/storage/operations/buckets/bucket-availability)
resource "yandex_storage_bucket" "image-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key-bucket.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key-bucket.secret_key
  bucket     = "${var.student_name}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

  max_size = 1024 # 1 Gb
  folder_id = var.yc_folder_id # не обязательно указывать в маленьком проекте, если не указать бакет создается в корневом каталоге проекта.
  default_storage_class = "STANDARD"

  anonymous_access_flags {
    read        = true    # публичный доступ на чтение объектов в бакете
    list        = false
    config_read = false
  }
}

//
// Create a new Storage Object in Bucket.
// https://terraform-provider.yandexcloud.net/resources/storage_object
resource "yandex_storage_object" "image" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key-bucket.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key-bucket.secret_key
  bucket     = yandex_storage_bucket.image-bucket.id
  key        = "image_file_s3_bucket.png"       # имя объекта после его добавления в бакет
  source     = "./image_file_s3_bucket.png"     # путь к локальному файлу
  acl        = "public-read"    # делаем файл публично доступным: https://yandex.cloud/ru/docs/storage/concepts/acl
}