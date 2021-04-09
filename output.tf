output "FortiGate_Public_IP" {
  value = ibm_is_floating_ip.publicip.address
}

output "Custom_Image_Name" {
  description = "Your local FortiGate Custom Image reference"
  value       = ibm_is_image.vnf_custom_image.name
}
output "Username" {
  value = "admin"
}

output "Default_Admin_Password" {
  value = ibm_is_instance.fgt1.id
}