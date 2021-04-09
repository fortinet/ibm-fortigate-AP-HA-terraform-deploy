

// Create the Custom image in your local cloud.
resource "ibm_is_image" "vnf_custom_image" {
  href             = var.image
  name             = "${var.cluster_name}-fortigate-custom-image-${random_string.random_suffix.result}"
  operating_system = "ubuntu-18-04-amd64"


  timeouts {
    create = "30m"
    delete = "10m"
  }
}
