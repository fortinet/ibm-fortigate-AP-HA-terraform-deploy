data "ibm_is_vpc" "vpc1" {
  name = var.VPC
}
//Subnets for primary (ACTIVE) FortiGate
data "ibm_is_subnet" "subnet1" {
  identifier = var.SUBNET_1
}
data "ibm_is_subnet" "subnet2" {
  identifier = var.SUBNET_2
}
data "ibm_is_subnet" "subnet3" {
  identifier = var.SUBNET_3
}
data "ibm_is_subnet" "subnet4" {
  identifier = var.SUBNET_4
}

data "ibm_is_security_group" "fgt_security_group_port1" {
  count = var.SECURITY_GROUP_PORT1 != "" ? 1 : 0
  name = var.SECURITY_GROUP_PORT1
}

data "ibm_is_security_group" "fgt_security_group_port2" {
  count = var.SECURITY_GROUP_PORT2 != "" ? 1 : 0
  name = var.SECURITY_GROUP_PORT2
}

resource "ibm_is_security_group" "fgt_security_group_port1" {
  count = var.SECURITY_GROUP_PORT1 == "" ? 1 : 0
  name  = "${var.CLUSTER_NAME}-fgt-sg-port1-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

resource "ibm_is_security_group" "fgt_security_group_port2" {
  count = var.SECURITY_GROUP_PORT2 == "" ? 1 : 0
  name  = "${var.CLUSTER_NAME}-fgt-sg-port2-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

locals {
  security_group_port1_id = var.SECURITY_GROUP_PORT1 != "" ? data.ibm_is_security_group.fgt_security_group_port1[0].id : ibm_is_security_group.fgt_security_group_port1[0].id
  security_group_port2_id = var.SECURITY_GROUP_PORT2 != "" ? data.ibm_is_security_group.fgt_security_group_port2[0].id : ibm_is_security_group.fgt_security_group_port2[0].id
  security_group_port1_name = var.SECURITY_GROUP_PORT1 != "" ? data.ibm_is_security_group.fgt_security_group_port1[0].name : ibm_is_security_group.fgt_security_group_port1[0].name
  security_group_port2_name = var.SECURITY_GROUP_PORT2 != "" ? data.ibm_is_security_group.fgt_security_group_port2[0].name : ibm_is_security_group.fgt_security_group_port2[0].name

}

locals {
  active = {
    "interface1" = {
      ip     = var.FGT1_STATIC_IP_PORT1,
      subnet = var.SUBNET_1
    },
    "interface2" = {
      ip     = var.FGT1_STATIC_IP_PORT2,
      subnet = var.SUBNET_2
    },
    "interface3" = {
      ip     = var.FGT1_STATIC_IP_PORT3,
      subnet = var.SUBNET_3
    },
    "interface4" = {
      ip     = var.FGT1_STATIC_IP_PORT4,
      subnet = var.SUBNET_4
    },
  }
  passive = {
    "interface1" = {
      ip     = var.FGT2_STATIC_IP_PORT1,
      subnet = var.SUBNET_1
    },
    "interface2" = {
      ip     = var.FGT2_STATIC_IP_PORT2,
      subnet = var.SUBNET_2
    },
    "interface3" = {
      ip     = var.FGT2_STATIC_IP_PORT3,
      subnet = var.SUBNET_3
    },
    "interface4" = {
      ip     = var.FGT2_STATIC_IP_PORT4,
      subnet = var.SUBNET_4
    },
  }

}

resource "ibm_is_virtual_network_interface" "vni-active" {
  for_each                  = local.active
  name                      = "${var.CLUSTER_NAME}-fgt1-${each.key}-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [local.security_group_port1_id]
  resource_group            = data.ibm_resource_group.rg.id

  primary_ip {
    auto_delete = false
    address     = each.value.ip
  }
  subnet = each.value.subnet
}

resource "ibm_is_virtual_network_interface" "vni-passive" {
  for_each                  = local.passive
  name                      = "${var.CLUSTER_NAME}-fgt2-${each.key}-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [local.security_group_port2_id]
  resource_group            = data.ibm_resource_group.rg.id

  primary_ip {
    auto_delete = false
    address     = each.value.ip
  }
  subnet = each.value.subnet
}