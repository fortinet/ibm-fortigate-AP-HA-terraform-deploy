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
data "ibm_is_security_group" "fgt_security_group" {
  name = var.SECURITY_GROUP
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
  security_groups           = [data.ibm_is_security_group.fgt_security_group.id]
  primary_ip {
    auto_delete = false
    reserved_ip = resource.ibm_is_subnet_reserved_ip.secondary-fgt-ips[each.key].name
  }
  subnet = each.value.subnet
}

resource "ibm_is_virtual_network_interface" "vni-passive" {
  for_each                  = local.passive
  name                      = "${var.CLUSTER_NAME}-fgt2-${each.key}-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  primary_ip {
    auto_delete = false
    address     = each.value.ip
    reserved_ip = resource.ibm_is_subnet_reserved_ip.secondary-fgt-ips[each.key].name
  }
  subnet = each.value.subnet
}

resource "ibm_is_subnet_reserved_ip" "primary-fgt-ips" {
  for_each    = local.active
  subnet      = each.value.subnet
  name        = "${var.CLUSTER_NAME}-fgt1-${each.key}-${random_string.random_suffix.result}"
  auto_delete = true
  target = ibm_is_virtual_network_interface.vni-active[each.key]
  }


resource "ibm_is_subnet_reserved_ip" "secondary-fgt-ips" {
  for_each    = local.passive
  subnet      = each.value.subnet
  name        = "${var.CLUSTER_NAME}-fgt2-${each.key}-${random_string.random_suffix.result}"
  auto_delete = true
  target = ibm_is_virtual_network_interface.vni-passive[each.key]
}