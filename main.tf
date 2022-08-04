module "VPC" {
  source = "github.com/krishnavamsi7616/tf-module-vpc"
  ENV = var.ENV
  PROJECT = var.PROJECT
  VPC_CIDR = var.VPC_CIDR
  PUBLIC_SUBNETS_CIDR  = var.PUBLIC_SUBNETS_CIDR
  PRIVATE_SUBNETS_CIDR = var.PRIVATE_SUBNETS_CIDR
  AZ = var.AZ
}