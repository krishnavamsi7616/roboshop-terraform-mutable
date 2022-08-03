module "VPC" {
  source = "github.com/krishnavamsi7616/tf-module-vpc"
  ENV = var.ENV
  PROJECT = var.PROJECT
  VPC_CIDR = var.VPC_CIDR
}