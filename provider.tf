terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.68.0"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  region           = var.REGION
  ibmcloud_api_key = var.IBMCLOUD_API_KEY
}
