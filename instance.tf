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
  name = "${var.CLUSTER_NAME}-publicip-${random_string.random_suffix.result}"
  zone    = var.ZONE

}
resource "ibm_is_floating_ip" "publicip2" {
  name = "${var.CLUSTER_NAME}-hamgmt-fgt1-${random_string.random_suffix.result}"
  zone    = var.ZONE

}
resource "ibm_is_floating_ip" "publicip3" {
  name = "${var.CLUSTER_NAME}-hamgmt-fgt2-${random_string.random_suffix.result}"
  zone    = var.ZONE

}
resource "ibm_is_virtual_network_interface_floating_ip" "public_ip" {
  virtual_network_interface = ibm_is_virtual_network_interface.vni-active["interface1"].id
  floating_ip               = ibm_is_floating_ip.publicip.id
}

resource "ibm_is_virtual_network_interface_floating_ip" "public_ip2" {
  virtual_network_interface = ibm_is_virtual_network_interface.vni-active["interface4"].id
  floating_ip               = ibm_is_floating_ip.publicip2.id
}

resource "ibm_is_virtual_network_interface_floating_ip" "public_ip3" {
  virtual_network_interface = ibm_is_virtual_network_interface.vni-passive["interface4"].id
  floating_ip               = ibm_is_floating_ip.publicip3.id
}

//Primary Fortigate
resource "ibm_is_instance" "fgt1" {
  name    = "${var.CLUSTER_NAME}-fortigate1-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.PROFILE

  primary_network_attachment {
    name = "${var.CLUSTER_NAME}-port1-fgt1-att-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-active["interface1"].id


    }
  }
  network_attachments {
    name = "${var.CLUSTER_NAME}-port2-fgt1-att-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-active["interface2"].id

    }
  }

  network_attachments {
    name = "${var.CLUSTER_NAME}-port3-fgt1-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-active["interface3"].id


    }
  }

  network_attachments {
    name = "${var.CLUSTER_NAME}-port4-fgt1-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-active["interface4"].id


    }
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

  primary_network_attachment {
    name = "${var.CLUSTER_NAME}-port1-fgt2-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface1"].id


    }
  }
  network_attachments {
    name = "${var.CLUSTER_NAME}-port2-fgt2-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface2"].id


    }
  }

  network_attachments {
    name = "${var.CLUSTER_NAME}-port3-fgt2-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface3"].id


    }
  }

  network_attachments {
    name = "${var.CLUSTER_NAME}-port4-fgt2-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface4"].id


    }
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

    netmask                  = var.NETMASK
    ibm_api_key              = var.IBMCLOUD_API_KEY
    region                   = var.IBMREGION[var.REGION]
    fgt2_port_4_mgmt_gateway = var.FGT2_PORT4_MGMT_GATEWAY
  }
}
