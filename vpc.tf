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

data "ibm_is_security_group" "fgt_security_group_public" {
  count = var.SECURITY_GROUP_PUBLIC != "" ? 1 : 0
  name  = var.SECURITY_GROUP_PUBLIC
}

data "ibm_is_security_group" "fgt_security_group_private" {
  count = var.SECURITY_GROUP_PRIVATE != "" ? 1 : 0
  name  = var.SECURITY_GROUP_PRIVATE
}

resource "ibm_is_security_group" "fgt_security_group_public" {
  count = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  name  = "${var.CLUSTER_NAME}-fgt-sg-public-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

resource "ibm_is_security_group" "fgt_security_group_private" {
  count = var.SECURITY_GROUP_PRIVATE == "" ? 1 : 0
  name  = "${var.CLUSTER_NAME}-fgt-sg-private-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

locals {
  security_group_public_id    = var.SECURITY_GROUP_PUBLIC != "" ? data.ibm_is_security_group.fgt_security_group_public[0].id : ibm_is_security_group.fgt_security_group_public[0].id
  security_group_private_id   = var.SECURITY_GROUP_PRIVATE != "" ? data.ibm_is_security_group.fgt_security_group_private[0].id : ibm_is_security_group.fgt_security_group_private[0].id
  security_group_public_name  = var.SECURITY_GROUP_PUBLIC != "" ? data.ibm_is_security_group.fgt_security_group_public[0].name : ibm_is_security_group.fgt_security_group_public[0].name
  security_group_private_name = var.SECURITY_GROUP_PRIVATE != "" ? data.ibm_is_security_group.fgt_security_group_private[0].name : ibm_is_security_group.fgt_security_group_private[0].name

}

#Rules to enable HA talk, only added to the private SG created by this template
resource "ibm_is_security_group_rule" "ingress_traffic" {
  count = var.SECURITY_GROUP_PRIVATE == "" ? 1 : 0
  group = ibm_is_security_group.fgt_security_group_private[0].id

  direction = "inbound"
  remote    = ibm_is_security_group.fgt_security_group_private[0].id
}

resource "ibm_is_security_group_rule" "egress_traffic" {
  count = var.SECURITY_GROUP_PRIVATE == "" ? 1 : 0
  group = ibm_is_security_group.fgt_security_group_private[0].id

  direction = "outbound"
  remote    = ibm_is_security_group.fgt_security_group_private[0].id
}

#Rules for the public SG created by this template (port1 public + port4 HA mgmt)
resource "ibm_is_security_group_rule" "public_ingress_https" {
  count     = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  group     = ibm_is_security_group.fgt_security_group_public[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
}

resource "ibm_is_security_group_rule" "public_ingress_ssh" {
  count     = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  group     = ibm_is_security_group.fgt_security_group_public[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

resource "ibm_is_security_group_rule" "public_ingress_fgfm" {
  count     = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  group     = ibm_is_security_group.fgt_security_group_public[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 541
  port_max  = 541
}

resource "ibm_is_security_group_rule" "public_ingress_ping" {
  count     = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  group     = ibm_is_security_group.fgt_security_group_public[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "icmp"
  type      = 8
}

#Outbound open for FortiGuard, licensing, the IBM SDN connector API calls and egress traffic through port1
resource "ibm_is_security_group_rule" "public_egress_all" {
  count     = var.SECURITY_GROUP_PUBLIC == "" ? 1 : 0
  group     = ibm_is_security_group.fgt_security_group_public[0].id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

locals {
  active = {
    "interface1" = {
      ip             = var.FGT1_STATIC_IP_PORT1,
      subnet         = var.SUBNET_1
      security_group = local.security_group_public_id
    },
    "interface2" = {
      ip             = var.FGT1_STATIC_IP_PORT2,
      subnet         = var.SUBNET_2
      security_group = local.security_group_private_id
    },
    "interface3" = {
      ip             = var.FGT1_STATIC_IP_PORT3,
      subnet         = var.SUBNET_3
      security_group = local.security_group_private_id
    },
    "interface4" = {
      ip             = var.FGT1_STATIC_IP_PORT4,
      subnet         = var.SUBNET_4
      security_group = local.security_group_public_id
    },
  }
  passive = {
    "interface1" = {
      ip             = var.FGT2_STATIC_IP_PORT1,
      subnet         = var.SUBNET_1
      security_group = local.security_group_public_id
    },
    "interface2" = {
      ip             = var.FGT2_STATIC_IP_PORT2,
      subnet         = var.SUBNET_2
      security_group = local.security_group_private_id
    },
    "interface3" = {
      ip             = var.FGT2_STATIC_IP_PORT3,
      subnet         = var.SUBNET_3
      security_group = local.security_group_private_id
    },
    "interface4" = {
      ip             = var.FGT2_STATIC_IP_PORT4,
      subnet         = var.SUBNET_4
      security_group = local.security_group_public_id
    },
  }

}

resource "ibm_is_virtual_network_interface" "vni-active" {
  for_each                  = local.active
  name                      = "${var.CLUSTER_NAME}-fgt1-${each.key}-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [each.value.security_group]
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
  security_groups           = [each.value.security_group]
  resource_group            = data.ibm_resource_group.rg.id

  primary_ip {
    auto_delete = false
    address     = each.value.ip
  }
  subnet = each.value.subnet
}
