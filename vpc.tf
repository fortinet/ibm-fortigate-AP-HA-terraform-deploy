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

# ============================================================================
# Security Group - Public (port1 external + port4 HA management)
# Inbound : self-referencing (inter-FGT only)
# Outbound: restricted to FortiGuard services required for licensing/DNS/updates
# ============================================================================

resource "ibm_is_security_group" "fgt_sg_public" {
  name           = "${var.CLUSTER_NAME}-sg-public-${random_string.random_suffix.result}"
  vpc            = data.ibm_is_vpc.vpc1.id
  resource_group = data.ibm_resource_group.rg.id
}

# Inbound - allow traffic only from interfaces in this same SG (inter-FGT)
resource "ibm_is_security_group_rule" "fgt_public_inbound_self" {
  group     = ibm_is_security_group.fgt_sg_public.id
  direction = "inbound"
  remote    = ibm_is_security_group.fgt_sg_public.id
  name      = "allow-inbound-from-same-sg"
}

# Inbound - TCP 443 for HTTPS admin GUI access
resource "ibm_is_security_group_rule" "fgt_public_inbound_https" {
  group     = ibm_is_security_group.fgt_sg_public.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
  name      = "allow-inbound-https-tcp-443"
}

# Outbound - UDP 53 for FortiGuard DNS & SDNS queries
resource "ibm_is_security_group_rule" "fgt_public_outbound_dns" {
  group     = ibm_is_security_group.fgt_sg_public.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "udp"
  port_min  = 53
  port_max  = 53
  name      = "allow-outbound-fortiguard-dns-udp-53"
}

# Outbound - TCP 443 for Licensing, FortiCare & Entitlements
resource "ibm_is_security_group_rule" "fgt_public_outbound_https" {
  group     = ibm_is_security_group.fgt_sg_public.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
  name      = "allow-outbound-fortiguard-licensing-tcp-443"
}

# Outbound - TCP 8890 for FortiGuard Distribution Updates (optional)
resource "ibm_is_security_group_rule" "fgt_public_outbound_fortiguard_updates" {
  group     = ibm_is_security_group.fgt_sg_public.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 8890
  port_max  = 8890
  name      = "allow-outbound-fortiguard-updates-tcp-8890"
}

# ============================================================================
# Security Group - Private (port2 internal + port3 HA heartbeat)
# Inbound : self-referencing (inter-FGT only)
# Outbound: self-referencing only — no internet access needed on private ports
# ============================================================================

resource "ibm_is_security_group" "fgt_sg_private" {
  name           = "${var.CLUSTER_NAME}-sg-private-${random_string.random_suffix.result}"
  vpc            = data.ibm_is_vpc.vpc1.id
  resource_group = data.ibm_resource_group.rg.id
}

# Inbound - allow traffic only from interfaces in this same SG (inter-FGT)
resource "ibm_is_security_group_rule" "fgt_private_inbound_self" {
  group     = ibm_is_security_group.fgt_sg_private.id
  direction = "inbound"
  remote    = ibm_is_security_group.fgt_sg_private.id
  name      = "allow-inbound-from-same-sg"
}

# Outbound - allow traffic only to interfaces in this same SG (inter-FGT)
resource "ibm_is_security_group_rule" "fgt_private_outbound_self" {
  group     = ibm_is_security_group.fgt_sg_private.id
  direction = "outbound"
  remote    = ibm_is_security_group.fgt_sg_private.id
  name      = "allow-outbound-to-same-sg"
}

locals {
  security_group_public_id    = ibm_is_security_group.fgt_sg_public.id
  security_group_private_id   = ibm_is_security_group.fgt_sg_private.id
  security_group_public_name  = ibm_is_security_group.fgt_sg_public.name
  security_group_private_name = ibm_is_security_group.fgt_sg_private.name
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
