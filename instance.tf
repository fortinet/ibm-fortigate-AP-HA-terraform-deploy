data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_public_key
}

resource "ibm_is_volume" "logDisk1" {
  // Name must be lower case
  name    = "${var.cluster_name}-logdisk1-${random_string.random_suffix.result}"
  profile = "10iops-tier"
  zone    = var.zone1
}

resource "ibm_is_volume" "logDisk2" {
  // Name must be lower case
  name    = "${var.cluster_name}-logdisk2-${random_string.random_suffix.result}"
  profile = "10iops-tier"
  zone    = var.zone2
}

resource "ibm_is_floating_ip" "publicip" {
  name   = "${var.cluster_name}-publicip-${random_string.random_suffix.result}"
  target = ibm_is_instance.fgt1.primary_network_interface[0].id
}

//Primary Fortigate
resource "ibm_is_instance" "fgt1" {
  name    = "${var.cluster_name}-fortigate1-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.profile

  primary_network_interface {
    name            = "${var.cluster_name}-port1-${random_string.random_suffix.result}"
    subnet          = data.ibm_is_subnet.subnet1.id
    security_groups = [data.ibm_is_security_group.fgt_security_group.id]
        primary_ipv4_address = var.primary_ipv4_fgt1
  }

  network_interfaces {
    name                 = "${var.cluster_name}-port2-${random_string.random_suffix.result}"
    subnet               = data.ibm_is_subnet.subnet2.id
    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]


  }

  volumes = [ibm_is_volume.logDisk1.id]

  vpc       = data.ibm_is_vpc.vpc1.id
  zone      = var.zone1
  user_data = data.template_file.userdata_active.rendered
  keys      = [data.ibm_is_ssh_key.ssh_key.id]]
}
// Secondary FortiGate
resource "ibm_is_instance" "fgt2" {
  name    = "${var.cluster_name}-fortigate2-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.profile

  primary_network_interface {
    name            = "${var.cluster_name}-port1-${random_string.random_suffix.result}"
    subnet          = data.ibm_is_subnet.zone_two_subnet_1.id
    security_groups = [data.ibm_is_security_group.fgt_security_group.id]
    primary_ipv4_address =var.primary_ipv4_fgt2
  }

  network_interfaces {
    name   = "${var.cluster_name}-port2-${random_string.random_suffix.result}"
       subnet          = data.ibm_is_subnet.zone_two_subnet_2.id

    security_groups      = [data.ibm_is_security_group.fgt_security_group.id]

  }

  volumes = [ibm_is_volume.logDisk2.id]

  vpc       = data.ibm_is_vpc.vpc1.id
  zone      = var.zone2
  user_data = data.template_file.userdata_passive.rendered
  keys      = [data.ibm_is_ssh_key.ssh_key.id]]
}

// Use for bootstrapping cloud-init
// Active Config template.
//TODO: files need to  be vars
data "template_file" "userdata_active" {
  template = file("user_data_active.conf")
  vars = {
    fgt_1_active_ip  = var.primary_ipv4_fgt1
    fgt_2_passive_ip = var.primary_ipv4_fgt2
    netmask          = "255.255.255.0"
    ibm_api_key = var.ibmcloud_api_key
    region = var.region
  }
}

// Passive Config Template.
data "template_file" "userdata_passive" {
  template = file("user_data_passive.conf")
  vars = {
    fgt_1_active_ip  = var.primary_ipv4_fgt1
    fgt_2_passive_ip =var.primary_ipv4_fgt2
    netmask          = "255.255.255.0"
    ibm_api_key = var.ibmcloud_api_key
    region = var.region
  }
}
