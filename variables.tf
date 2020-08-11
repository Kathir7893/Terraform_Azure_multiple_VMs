
variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_names" {
  type    = list(string)
  default = ["VM1", "VM2"]
}

variable "env_tag" {
  type    = string
  default = "TF_VM_DEMO"
}

variable "region" {
  type    = string
  default = "eastus"
}
