## Description

A Terraform script to deploy an Active-Passive (A-P) HA cluster in a single zone. This template makes use of the FortiGate IBM SDN connector to failover in the event of a VM shutdown.
After the active VM is back up, it will take over as active once again.

## Requirements

-   [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) 0.13+
-   Two FortiOS 7.0 BYOL Licenses.
-   [A VPC with four subnets in a single zone](https://cloud.ibm.com/docs/vpc/vpc-getting-started-with-ibm-cloud-virtual-private-cloud-infrastructure)
-   [A configured IBM SSH key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)
-   [A security group](https://cloud.ibm.com/docs/security-groups?topic=security-groups-about-ibm-security-groups)

## Deployment overview

> **Note:** For a local deployment, a Gen 2 API key will be needed. For details see [IBM Gen 2 API key](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key).

Terraform deploys the following components:

-   Two FortiGate BYOL instances with four NICs each, one in each subnet.
-   Three floating Public IP addresses: one attached to the Primary FortiGate on Port1, which will failover and the other two attached to the HA management port (Port4) of each FortiGate.
-   One log disk per FortiGate.
-   A basic bootstrap configuration with HA support.

# Deployment Diagram

![IBM FortiGate Diagram](https://raw.githubusercontent.com/fortinet/ibm-fortigate-AP-HA-terraform-deploy/main/imgs/IBM_ha-diagram-singlezone.png)

## Deployment

> **Note:** For Subnets, the UUID is required.

1. Fill in the required Subnets, security group and VPC information as shown in the example below:


   ![IBM FortiGate Example Inputs](https://raw.githubusercontent.com/fortinet/ibm-fortigate-AP-HA-terraform-deploy/main/imgs/IBM_ha_example.png)

  

3. Apply the plan.
4. Outputs, such as the **Public IP** and **Default username and password** can be found under the `View Log` link.

## Destroy the cluster

To destroy the cluster, click on `Actions...`->`Destroy`.

# Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/ibm-fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License

[License](https://github.com/fortinet/ibm-fortigate-terraform-deploy/blob/main/LICENSE) © Fortinet Technologies. All rights reserved.
