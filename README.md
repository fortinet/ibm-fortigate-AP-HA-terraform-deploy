## Description

A Terraform script to deploy an Acitve-Passive (A-P) HA cluster in a single Zone. This template makes use of the FortiGate IBM SDN connector to failover in the event of a VM shutdown.
After the Active VM is brought back up, it will take over as active once again.

## Requirements

-   [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) 0.13+
-   Two FortiOS 7.0 BYOL Licenses.
-   A VPC with four subnets in a single zone.
-   An IBM ssh key configured.
-   A security group

## Deployment overview

> **Note:** For a local deployment a Gen 2 API key will be needed. For details see: [IBM Gen 2 API key](https://cloud.ibm.com/docs/terraform?topic=terraform-provider-reference)

Terraform deploys the following components:

-   Two FortiGate BYOL instances with four NICs, one in each subnet
-   Three Floating Public IPs: One attached to the Primary FortiGate on Port1, which will failover. One attached, per FortiGate to the HA management port (Port4).
-   A Logging disk per FortiGate
-   A basic bootstrap config, with HA support.

# Deployment Diagram

![IBM FortiGate Diagram](https://raw.githubusercontent.com/fortinet/ibm-fortigate-terraform-deploy/main/imgs/IBM_ha-diagram-singlezone.png)

## Deployment

1. From the IBM console navitagte to Schematics.
2. Fill in the workspace info and create your workspace.
3. Copy the repo URL into repository URL field and then select Terraform version 0.13.

    ![IBM FortiGate Deploy](./imgs/step_3.png)

4. Add in your ssh key and adjust any Variables as needed in the settings.

    ![IBM FortiGate Deploy](./imgs/step_4.png)

5. Apply the plan.
6. Outputs, such as the **Public IP** and **Default username and password** can be found under the `View Log` link.

    ![IBM FortiGate Deploy](./imgs/step_6_a.png)
    ![IBM FortiGate Deploy](./imgs/step_6_b.png)

## Destroy the cluster

To destroy the cluster, click on `Actions...`->`Destroy`

![IBM FortiGate Deploy](./imgs/destroy_cluster.png)

# Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/ibm-fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License

[License](https://github.com/fortinet/ibm-fortigate-terraform-deploy/blob/main/LICENSE) © Fortinet Technologies. All rights reserved.
