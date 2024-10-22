variable "tags" {
  type = map(string)
  default = {
    application = "latam-engage"
    environment = "production"
    team = "devops"
    customer = "latam"
    contact-email = ""
  }
}

variable "container_name" {
  default = "latam-engage"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "name" {
  default = "latam-engage"
}