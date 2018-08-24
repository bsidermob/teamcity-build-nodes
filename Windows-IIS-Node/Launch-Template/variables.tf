variable "template_name" {
  default = "Dev-VM-template"
}

variable "ami_name" {
  default = "TeamCity-BuildNode-IIS-Windows"
}

variable "security_groups" {
  default = [
    "sg-"
  ]
}

variable "subnet_id" {
  default = "subnet-"
}

variable "tag" {
  default = "Dev-VM"
}
