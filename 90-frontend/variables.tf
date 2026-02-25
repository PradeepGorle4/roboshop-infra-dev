variable "common_tags" {
  default = {
    project     = "roboshop"
    environment = "dev"
    terraform   = true
  }
}

variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "domain_name" {
  default = "devopslife.store"
}