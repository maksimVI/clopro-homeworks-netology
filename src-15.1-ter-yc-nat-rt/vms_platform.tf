variable "vms_resources" {
  type = map(object({
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  }))
  description = "Resources for VMs"
}

variable "vms_metadata" {
  type = map(object({
    serial_port_enable  = number
    keys                = string
  }))
  description = "Metadata for VMs"
}