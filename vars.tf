# Your SSH key
variable "ssh_public_key" {
  default     = ""
  description = "Copy in a public ssh key to be used with the FortiGate. Required Value."
}
// Magic Value for Calalog Validation that initlizes terraform with a specific version.
// Only needed in IBM catalog.
variable "TF_VERSION" {
  default     = "0.13"
  description = "Terraform version to be used in validation"
}

// IBM Regions
variable "region" {
  type        = string
  default     = "us-south"
  description = "Deployment Region"
}
// IBM availability zones
variable "zone1" {
  type        = string
  default     = "us-south-1"
  description = "Deployment Zone Primary(Active) FortiGate."
}
variable "zone2" {
  type        = string
  default     = "us-south-2"
  description = "Secondary Zone for Secondary(Passive) FortiGate."
}
variable "vpc" {
  type        = string
  default     = ""
  description = "Name of the VPC you want to deploy a FortiGate into."
}
variable "subnet1" {
  type        = string
  default     = ""
  description = "The Primary, Public Subnet Used for port1 on the FortiGate"
}
variable "subnet2" {
  type        = string
  default     = ""
  description = "The Secondary, Private Subnet Used for port2 on the FortiGate"
}
variable "zone_two_subnet_1" {
  type =  string
  default = ""
  description = "The Primary Subnet of the second zone"
}
variable "zone_two_subnet_2" {
  type =  string
  default = ""
  description = "The Secondary Subnet of the second zone"
}
variable "netmask" {
  type        = string
  default     = "255.255.255.0"
  description = "Subnet Mask for Static IP and Nic of each FortiGate."
}

variable "primary_ipv4_fgt1" {
  type        = string
  default     = ""
  description = "IP Assignment for the Primary (Active) FortiGate Port1."
}

variable "primary_ipv4_fgt2" {
  type        = string
  default     = ""
  description = "IP Assignment for the Secondary (Passive) FortiGate Port1."
}

variable "security_group" {
  type        = string
  default     = ""
  description = "The Security Group to attach to the FortiGate Instance Network Interfaces."
}


// Name will be in the format of cluster_name-RESOURCE-randomSuffix to be easily identifiable.
// Name must be lowercase
variable "cluster_name" {
  type    = string
  default = "fortigate-terraform"
}
// Random Suffix to avoid name collisions and identify cluster.
resource "random_string" "random_suffix" {
  length           = 4
  special          = true
  override_special = ""
  min_lower        = 4
}


// FortiOS Custom Image ID
// https://docs.fortinet.com/vm/ibm/fortigate/6.4/ibm-cloud-cookbook/6.4.2/992669/deploying-fortigate-vm-on-ibm-cloud
// Deploys 6.4.3 Image
// 6.4.4 available link: cos://us-geo/fortinet/fortigate_byol_644_b1803_GA.qcow2
// cos://us-geo/fortinet/fortigate_byol_700_b0066_GA.qcow2 7.0
variable "image" {
  default = "cos://us-geo/fortinet/fortigate_byol_644_b1803_GA.qcow2"
}
variable "ibmcloud_api_key" {
  default = ""
}
// Default Instance type
// See: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles
variable "profile" {
  default     = "cx2-2x4"
  description = "VM size and family"
}
