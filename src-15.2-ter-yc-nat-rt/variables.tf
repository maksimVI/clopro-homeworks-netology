variable "yc_token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
  sensitive   = true    # Подавление значений в выводе CLI https://developer.hashicorp.com/terraform/language/values/variables#suppressing-values-in-cli-output
}

variable "yc_cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "yc_folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "student_name" {
  default = "maksim-vi"   # имена бакетов в S3 только строчные латинские буквы (a-z), цифры (0-9) и дефисы (-)
}