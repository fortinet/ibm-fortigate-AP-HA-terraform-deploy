output "FortiGate_Public_IP" {
  value = ibm_is_floating_ip.publicip.address
}
output "FGT1_Public_HA_Mangment_IP" {
  value = ibm_is_floating_ip.publicip2.address
}
output "FGT2_Public_HA_Mangment_IP" {
  value = ibm_is_floating_ip.publicip3.address
}
output "Custom_Image_Name" {
  description = "Your local FortiGate Custom Image reference"
  value       = ibm_is_image.vnf_custom_image.name
}
output "Username" {
  value = "admin"
}

output "FGT1_Default_Admin_Password" {
  value = ibm_is_instance.fgt1.id
}
output "FGT2_Default_Admin_Password" {
  value = ibm_is_instance.fgt2.id
}