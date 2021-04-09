# resource "ibm_is_vpc" "vpc1" {
#   name = "${var.cluster_name}-vpc-${random_string.random_suffix.result}"
# }

data "ibm_is_vpc" "vpc1" {
  name = var.vpc
}
data "ibm_is_subnet" "subnet1" {
  name = var.subnet1
}
data "ibm_is_subnet" "subnet2" {
  name = var.subnet2
}
data "ibm_is_subnet" "zone_two_subnet_1" {
  name = var.zone_two_subnet_1
}
data "ibm_is_subnet" "zone_two_subnet_2" {
  name = var.zone_two_subnet_2
}


resource "ibm_is_vpc_routing_table" "fgt_route_table" {
  name = "${var.cluster_name}-port1-${random_string.random_suffix.result}"
  vpc  = data.ibm_is_vpc.vpc1.id
}


data "ibm_is_security_group" "fgt_security_group" {
  name = var.security_group
}
