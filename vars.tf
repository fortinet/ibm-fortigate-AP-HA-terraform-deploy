# Your SSH key
variable "SSH_PUBLIC_KEY" {
  default     = ""
  description = "The name(ID) of your SSH public key to be used."
}
// Magic Value for Catalog Validation that initializes Terraform with a specific version.
// Only needed in IBM catalog.
variable "TF_VERSION" {
  default     = "0.13"
  description = "Terraform version to be used in validation."
}

// IBM Regions
variable "REGION" {
  type        = string
  default     = "us-east"
  description = "Deployment region."
}
// IBM availability zones
variable "ZONE" {
  type        = string
  default     = "us-east-1"
  description = "Deployment zone. Currently only a single zone is supported."
}

variable "VPC" {
  type        = string
  default     = ""
  description = "Name of the VPC you want to deploy a FortiGate into."
}

variable "SUBNET_1" {
  type        = string
  default     = ""
  description = "The ID of the Primary, Public Subnet Used for port1 on the FortiGate"
}
variable "SUBNET_2" {
  type        = string
  default     = ""
  description = "The ID of the Secondary, Private Subnet Used for port2 on the  FortiGate"
}
variable "SUBNET_3" {
  type        = string
  default     = ""
  description = "The ID of the Subnet for the HA heartbeat mechanism. Tied to Port3"
}
variable "SUBNET_4" {
  type        = string
  default     = ""
 description = "The ID of the Subnet used for the HA mangment subnet. Tied to Port4"
}

variable "NETMASK" {
  type        = string
  default     = "255.255.255.0"
description = "Subnet mask for the static IP address and NIC of each FortiGate."
}

variable "FGT1_STATIC_IP_PORT1" {
  type        = string
  default     = ""
description = "Static IP assignment for Port 1 of the Primary (ACTIVE) FortiGate."
}
variable "FGT1_STATIC_IP_PORT2" {
  type        = string
  default     = ""
description = "Static IP assignment for Port 2 of the Primary (ACTIVE) FortiGate."
}
// Used for HA Heartbeat mechanism.
variable "FGT1_STATIC_IP_PORT3" {
  type        = string
  default     = ""
  description = "Port used for the HA Heartbeat mechanism."
}
// Used as the HA Management port.
variable "FGT1_STATIC_IP_PORT4" {
  type        = string
  default     = ""
  description = "HA management port"
}
variable "FGT1_PORT4_MGMT_GATEWAY" {
  type        = string
  default     = ""
  description = "Gateway for Port 4 (HA management port) on the primary (ACTIVE) FortiGate."
}
// FortiGate 2 (PASSIVE) PORTS
variable "FGT2_STATIC_IP_PORT1" {
  type        = string
  default     = ""
  description = "STATIC IP Assignment for Port 1 on the Secondary (PASSIVE) FortiGate."
}
variable "FGT2_STATIC_IP_PORT2" {
  type        = string
  default     = ""
  description = "STATIC IP Assignment for Port 2 on the Secondary (PASSIVE) FortiGate."
}
// Used for HA Heartbeat mechanism.
variable "FGT2_STATIC_IP_PORT3" {
  type        = string
  default     = ""
  description = "Port used for the HA Heartbeat mechanism."
}
// Used as the HA Mangment port.
variable "FGT2_STATIC_IP_PORT4" {
  type        = string
  default     = ""
  description = "HA mangment port"
}
variable "FGT2_PORT4_MGMT_GATEWAY" {
  type        = string
  default     = ""
  description = "Gateway for Port 4 (HA management port) on the secondary (PASSIVE) FortiGate."
}
variable "SECURITY_GROUP" {
  type        = string
  default     = ""
  description = "The Security Group to attach to the FortiGate instance Network Interfaces."
}


// For easy identification, the name of the cluster uses the format cluster-name-resource-randomSuffix."
// Name must be lowercase.
variable "CLUSTER_NAME" {
  type        = string
  default     = "fortigate-terraform"
  description = "Name of the cluster (must be lowercase). For easy identification, the format cluster-name-resource-randomSuffix is used."
}
// Random suffix to avoid cluster name collisions and help identify the  cluster.
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
  default = "cos://us-geo/fortinet/fortigate_byol_700_b0066_GA.qcow2"
}
variable "IBMCLOUD_API_KEY" {
  default     = ""
  description = "Your IBM USER API key. Refer to the README for links to documentation for IBM API keys. This value is required for the SDN Connector for HA SYNC."

}
// Default Instance type
// See: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles
variable "PROFILE" {
  default     = "cx2-2x4"
  description = "VM size and family. See README for links to documentation on IBM instance types."
}
