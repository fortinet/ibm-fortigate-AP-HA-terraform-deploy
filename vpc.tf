data "ibm_is_vpc" "vpc1" {
  name = var.VPC
}
//Subnets for primary (ACTIVE) FortiGate
data "ibm_is_subnet" "subnet1" {
  name = var.SUBNET_1
}
data "ibm_is_subnet" "subnet2" {
  name = var.SUBNET_2
}
data "ibm_is_subnet" "subnet3" {
  name = var.SUBNET_3
}
data "ibm_is_subnet" "subnet4" {
  name = var.SUBNET_4
}
data "ibm_is_security_group" "fgt_security_group" {
  name = var.SECURITY_GROUP
}
