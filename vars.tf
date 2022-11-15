# Your SSH key
variable "SSH_PUBLIC_KEY" {
  default     = ""
  description = "The name(ID) of your SSH public key to be used."
}
// Magic Value for Catalog Validation that initializes Terraform with a specific version.
// Only needed in IBM catalog.
variable "TF_VERSION" {
  default     = "1.1"
  description = "Terraform version to be used in validation."
}

// IBM Regions
variable "REGION" {
  type        = string
  default     = "us-east"
  description = "Deployment region."
}

// IBM region map for FortiOS
variable "IBMREGION" {
  type = map(string)
  default = {
    "us-south" = "dallas-private"
    "us-east"  = "washington-dc-private"
    "ca-tor"   = "toronto-private"
    "br-sao"   = "sao-paolo-private"
    "eu-gb"    = "london-private"
    "eu-de"    = "frankfurt-private"
    "au-syd"   = "sydney-private"
    "jp-tok"   = "tokyo-private"
    "jp-osa"   = "osaka-private"
  }
  description = "Map used to configure sdn connector for IBM in FortiOS"
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
  description = "The ID of the Primary, Public Subnet Used for port1 on the FortiGate."
}
variable "SUBNET_2" {
  type        = string
  default     = ""
  description = "The ID of the Secondary, Private Subnet Used for port2 on the FortiGate."
}
variable "SUBNET_3" {
  type        = string
  default     = ""
  description = "The ID of the Subnet for the HA heartbeat mechanism. Tied to Port3."
}
variable "SUBNET_4" {
  type        = string
  default     = ""
  description = "The ID of the Subnet used for the HA management subnet. Tied to Port4."
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
  description = "HA management port."
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
// Used as the HA management port.
variable "FGT2_STATIC_IP_PORT4" {
  type        = string
  default     = ""
  description = "HA management port."
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
// https://docs.fortinet.com/document/fortigate-public-cloud/7.0.0/ibm-cloud-administration-guide/324064/ha-for-fortigate-vm-on-ibm-cloud
//Deploys 7.2.2 Image
variable "image" {
  default = "cos://us-geo/fortinet/fortigate_byol_723_b1262_GA.qcow2"
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
