data "ibm_is_vpc" "vpc1" {
  name = var.VPC
}
//Subnets for primary (ACTIVE) FortiGate
data "ibm_is_subnet" "subnet1" {
  name = var.ZONE1_SUBNET_1
}
data "ibm_is_subnet" "subnet2" {
  name = var.ZONE1_SUBNET_2
}
data "ibm_is_subnet" "subnet3" {
  name = var.ZONE1_SUBNET_3
}
data "ibm_is_subnet" "subnet4" {
  name = var.ZONE1_SUBNET_4
}
//Subnets for primary (Passive) FortiGate
data "ibm_is_subnet" "zone_two_subnet_1" {
  name = var.ZONE2_SUBNET_1
}
data "ibm_is_subnet" "zone_two_subnet_2" {
  name = var.ZONE2_SUBNET_2
}
data "ibm_is_subnet" "zone_two_subnet_3" {
  name = var.ZONE2_SUBNET_3
}
data "ibm_is_subnet" "zone_two_subnet_4" {
  name = var.ZONE2_SUBNET_4
}
data "ibm_is_security_group" "fgt_security_group" {
  name = var.SECURITY_GROUP
}
