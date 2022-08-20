module "VPC" {
  source                = "github.com/krishnavamsi7616/tf-module-vpc"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  VPC_CIDR              = var.VPC_CIDR
  PUBLIC_SUBNETS_CIDR   = var.PUBLIC_SUBNETS_CIDR
  PRIVATE_SUBNETS_CIDR  = var.PRIVATE_SUBNETS_CIDR
  AZ                    = var.AZ
  DEFAULT_VPC_ID        = var.DEFAULT_VPC_ID
  DEFAULT_VPC_CIDR      = var.DEFAULT_VPC_CIDR
  DEFAULT_VPC_RT        = var.DEFAULT_VPC_RT
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PUBLIC_ZONE_ID        = var.PUBLIC_ZONE_ID
}


module "RDS" {
  source                = "github.com/krishnavamsi7616/tf-module-rds"
  ENV                   = var.ENV
  ENGINE                = var.RDS_ENGINE
  PROJECT               = var.PROJECT
  ENGINE_VERSION        = var.RDS_ENGINE_VERSION
  RDS_INSTANCE_CLASS    = var.RDS_INSTANCE_CLASS
  PG_FAMILY             = var.RDS_PG_FAMILY
  VPC_ID                = module.VPC.VPC_ID
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  RDS_PORT              = var.RDS_PORT
  ALLOW_SG_CIDR         = concat(module.VPC.PRIVATE_SUBNET_CIDR,tolist([var.WORKSTATION_IP]))
}

module "DOCDB" {
  source                = "github.com/krishnavamsi7616/tf-module-docdb"
  ENV                   = var.ENV
  ENGINE                = var.DOCDB_ENGINE
  ENGINE_VERSION        = var.DOCDB_ENGINE_VERSION
  PROJECT               = var.PROJECT
  INSTANCE_CLASS        = var.DOCDB_INSTANCE_CLASS
  PG_FAMILY             = var.DOCDB_PG_FAMILY
  VPC_ID                = module.VPC.VPC_ID
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  PORT                  = var.DOCDB_PORT
  ALLOW_SG_CIDR         = concat(module.VPC.PRIVATE_SUBNET_CIDR,tolist([var.WORKSTATION_IP]))
  NUMBER_OF_NODES       = var.DOCDB_NUMBER_OF_NODES
}

module "ELASTICACHE" {
  source                = "github.com/krishnavamsi7616/tf-module-elasticache"
  ENV                   = var.ENV
  ENGINE                = var.ELASTICACHE_ENGINE
  ENGINE_VERSION        = var.ELASTICACHE_ENGINE_VERSION
  PROJECT               = var.PROJECT
  INSTANCE_CLASS        = var.ELASTICACHE_INSTANCE_CLASS
  PG_FAMILY             = var.ELASTICACHE_PG_FAMILY
  VPC_ID                = module.VPC.VPC_ID
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  PORT                  = var.ELASTICACHE_PORT
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  NUMBER_OF_NODES       = var.ELASTICACHE_NUMBER_OF_NODES
}

module "RABBITMQ" {
  source                = "github.com/krishnavamsi7616/tf-module-rabbitmq"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  PORT                  = var.RABBITMQ_PORT
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  INSTANCE_TYPE         = var.RABBITMQ_INSTANCE_TYPE
  WORKSTATION_IP        = var.WORKSTATION_IP
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
}

module "LB" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-lb"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  PUBLIC_SUBNET_IDS     = module.VPC.PUBLIC_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PUBLIC_ZONE_ID        = var.PUBLIC_ZONE_ID
}

module "FRONTEND" {
  #depends_on = [module.CART, module.CATALOGUE, module.PAYMENT, module.SHIPPING, module.USER]
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = concat(module.VPC.PRIVATE_SUBNET_CIDR,module.VPC.PUBLIC_SUBNET_CIDR)
  PORT                  = 80
  COMPONENT             = "frontend"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["FRONTEND"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["FRONTEND"]["COUNT"]
  LB_ARN                = module.LB.PUBLIC_LB_ARN
  LB_TYPE               = "public"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}

module "CART" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PORT                  = 8080
  COMPONENT             = "cart"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["CART"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["CART"]["COUNT"]
  LB_ARN                = module.LB.PRIVATE_LB_ARN
  LB_TYPE               = "private"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  REDIS_ENDPOINT       = module.ELASTICACHE.REDIS_ENDPOINT
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}


module "CATALOGUE" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PORT                  = 8080
  COMPONENT             = "catalogue"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["CATALOGUE"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["CATALOGUE"]["COUNT"]
  LB_ARN                = module.LB.PRIVATE_LB_ARN
  LB_TYPE               = "private"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  DOCDB_ENDPOINT        = module.DOCDB.DOCDB_ENDPOINT
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}


module "USER" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PORT                  = 8080
  COMPONENT             = "user"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["USER"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["USER"]["COUNT"]
  LB_ARN                = module.LB.PRIVATE_LB_ARN
  LB_TYPE               = "private"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  DOCDB_ENDPOINT        = module.DOCDB.DOCDB_ENDPOINT
  REDIS_ENDPOINT        = module.ELASTICACHE.REDIS_ENDPOINT
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}

module "SHIPPING" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PORT                  = 8080
  COMPONENT             = "shipping"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["SHIPPING"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["SHIPPING"]["COUNT"]
  LB_ARN                = module.LB.PRIVATE_LB_ARN
  LB_TYPE               = "private"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  MYSQL_ENDPOINT        = module.RDS.MYSQL_ENDPOINT
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}


module "PAYMENT" {
  source                = "github.com/krishnavamsi7616/tf-module-mutable-app"
  ENV                   = var.ENV
  PROJECT               = var.PROJECT
  PRIVATE_SUBNET_IDS    = module.VPC.PRIVATE_SUBNET_IDS
  VPC_ID                = module.VPC.VPC_ID
  ALLOW_SG_CIDR         = module.VPC.PRIVATE_SUBNET_CIDR
  PORT                  = 8080
  COMPONENT             = "payment"
  INSTANCE_TYPE         = var.INSTANCE_COUNT["PAYMENT"]["INSTANCE_TYPE"]
  WORKSTATION_IP        = var.WORKSTATION_IP
  INSTANCE_COUNT        = var.INSTANCE_COUNT["PAYMENT"]["COUNT"]
  LB_ARN                = module.LB.PRIVATE_LB_ARN
  LB_TYPE               = "private"
  PRIVATE_LB_DNS        = module.LB.PRIVATE_LB_DNS
  PRIVATE_ZONE_ID       = var.PRIVATE_ZONE_ID
  PRIVATE_LISTENER_ARN  = module.LB.PRIVATE_LISTENER_ARN
  PROMETHEUS_IP         = var.PROMETHEUS_IP
}


