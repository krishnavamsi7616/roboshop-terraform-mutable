variable "PROJECT" {}
variable "ENV" {}


//VPC
variable "VPC_CIDR" {}
variable "PRIVATE_SUBNETS_CIDR" {}
variable "PUBLIC_SUBNETS_CIDR" {}
variable "AZ" {}
variable "DEFAULT_VPC_ID" {}
variable "DEFAULT_VPC_CIDR" {}
variable "DEFAULT_VPC_RT" {}



//RDS
variable "ENGINE" {}
variable "ENGINE_VERSION" {}
variable "RDS_INSTANCE_CLASS" {}
variable "PG_FAMILY" {}
variable "PRIVATE_SUBNET_IDS" {}
variable "VPC_ID" {}
variable "RDS_PORT" {}
variable "ALLOW_SG_CIDR" {}
