data "ibm_is_ssh_key" "ssh_key" {
  name = var.SSH_PUBLIC_KEY
}

resource "ibm_is_volume" "logDisk1" {
  // Name must be lower case
  name    = "${var.CLUSTER_NAME}-logdisk1-${random_string.random_suffix.result}"
  profile = "10iops-tier"
  zone    = var.ZONE
}

resource "ibm_is_volume" "logDisk2" {
  // Name must be lower case
  name    = "${var.CLUSTER_NAME}-logdisk2-${random_string.random_suffix.result}"
  profile = "10iops-tier"
  zone    = var.ZONE
}

resource "ibm_is_floating_ip" "publicip" {
  name   = "${var.CLUSTER_NAME}-publicip-${random_string.random_suffix.result}"
  target = ibm_is_instance.fgt1.primary_network_interface[0].id
}
resource "ibm_is_floating_ip" "publicip2" {
  name   = "${var.CLUSTER_NAME}-hamgmt-fgt1-${random_string.random_suffix.result}"
  target = ibm_is_instance.fgt1.network_interfaces[2].id // fourth port.
}
resource "ibm_is_floating_ip" "publicip3" {
  name   = "${var.CLUSTER_NAME}-hamgmt-fgt2-${random_string.random_suffix.result}"
  target = ibm_is_instance.fgt2.network_interfaces[2].id //fourth port.
}

//Primary Fortigate
resource "ibm_is_instance" "fgt1" {
  name    = "${var.CLUSTER_NAME}-fortigate1-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.PROFILE


  primary_network_interface {
    name                 = "${var.CLUSTER_NAME}-port1-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet1.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT1_STATIC_IP_PORT1
  }

  network_interfaces {
    name                 = "${var.CLUSTER_NAME}-port2-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet2.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT1_STATIC_IP_PORT2


  }
  network_interfaces {
    name                 = "${var.CLUSTER_NAME}-port3-ha-heartbeat-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet3.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT1_STATIC_IP_PORT3


  }
  network_interfaces {
    name                 = "${var.CLUSTER_NAME}-port4-ha-mgmt-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet4.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT1_STATIC_IP_PORT4


  }

  volumes = [ibm_is_volume.logDisk1.id]

  vpc       = data.ibm_is_vpc.vpc1.id
  zone      = var.ZONE
  user_data = data.template_file.userdata_active.rendered
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  // Timeout issues persist. See https://www.ibm.com/cloud/blog/timeout-errors-with-ibm-cloud-schematics
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
  // Force IBM to recover from perpetual 'starting state' see:
  // https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_instance#force_recovery_time
  force_recovery_time = 20
}

// Secondary FortiGate
resource "ibm_is_instance" "fgt2" {
  name    = "${var.CLUSTER_NAME}-fortigate2-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.PROFILE

  primary_network_interface {
    name                 = "${var.CLUSTER_NAME}-port1-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet1.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT2_STATIC_IP_PORT1
  }

  network_interfaces {
    name   = "${var.CLUSTER_NAME}-port2-${random_string.random_suffix.result}"
    subnet = data.ibm_is_subnet.subnet2.id

    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT2_STATIC_IP_PORT2

  }
  network_interfaces {
    name                 = "${var.CLUSTER_NAME}-port3-ha-heartbeat-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet3.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT2_STATIC_IP_PORT3
  }
  network_interfaces {
    name                 = "${var.CLUSTER_NAME}-port4-ha-mgmt-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet4.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address = var.FGT2_STATIC_IP_PORT4
  }

  volumes = [ibm_is_volume.logDisk2.id]

  vpc       = data.ibm_is_vpc.vpc1.id
  zone      = var.ZONE
  user_data = data.template_file.userdata_passive.rendered
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  //Timeout issues persist. See https://www.ibm.com/cloud/blog/timeout-errors-with-ibm-cloud-schematics
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
  // Force IBM to recover from perpetual 'starting state' see:
  // https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_instance#force_recovery_time
  force_recovery_time = 20
}

// Use for bootstrapping cloud-init
// Active Config template.
//TODO: files need to  be vars
data "template_file" "userdata_active" {
  template = file("user_data_active.conf")
  vars = {
    fgt_1_static_port1 = var.FGT1_STATIC_IP_PORT1
    fgt_1_static_port2 = var.FGT1_STATIC_IP_PORT2
    fgt_1_static_port3 = var.FGT1_STATIC_IP_PORT3
    fgt_1_static_port4 = var.FGT1_STATIC_IP_PORT4

    fgt_2_static_port1 = var.FGT2_STATIC_IP_PORT1
    fgt_2_static_port2 = var.FGT2_STATIC_IP_PORT2
    fgt_2_static_port3 = var.FGT2_STATIC_IP_PORT3
    fgt_2_static_port4 = var.FGT2_STATIC_IP_PORT4

    netmask                  = var.NETMASK
    ibm_api_key              = var.IBMCLOUD_API_KEY
    region                   = var.IBMREGION[var.REGION]
    fgt1_port_4_mgmt_gateway = var.FGT1_PORT4_MGMT_GATEWAY

  }
}

// Passive Config Template.
data "template_file" "userdata_passive" {
  template = file("user_data_passive.conf")
  vars = {
    fgt_1_static_port1 = var.FGT1_STATIC_IP_PORT1
    fgt_1_static_port2 = var.FGT1_STATIC_IP_PORT2
    fgt_1_static_port3 = var.FGT1_STATIC_IP_PORT3
    fgt_1_static_port4 = var.FGT1_STATIC_IP_PORT4

    fgt_2_static_port1 = var.FGT2_STATIC_IP_PORT1
    fgt_2_static_port2 = var.FGT2_STATIC_IP_PORT2
    fgt_2_static_port3 = var.FGT2_STATIC_IP_PORT3
    fgt_2_static_port4 = var.FGT2_STATIC_IP_PORT4

    netmask     = var.NETMASK
    ibm_api_key = var.IBMCLOUD_API_KEY
    region      = var.IBMREGION[var.REGION]
    fgt2_port_4_mgmt_gateway = var.FGT2_PORT4_MGMT_GATEWAY
  }
}
