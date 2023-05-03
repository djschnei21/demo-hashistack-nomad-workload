# HashiStack Demo Project

This repository contains a demo project showcasing integration of the HashiStack, which includes [Vault](https://www.vaultproject.io/), [Consul](https://www.consul.io/), [Nomad](https://www.nomadproject.io/), and [Terraform](https://www.terraform.io/). The project deploys a MongoDB instance and a dashboard application onto Nomad, demonstrating the use of dynamic secrets, service mesh, and service discovery features provided by the HashiStack.

## Features

### Dynamic Secrets

This demo project leverages Vault's [MongoDB Secrets Engine](https://www.vaultproject.io/docs/secrets/databases/mongodb) to generate dynamic, short-lived credentials for the MongoDB instance. The dashboard application retrieves these credentials from Vault and uses them to connect to the MongoDB instance. This approach enhances security by reducing the need for long-lived, shared credentials and enables automated credential rotation.

### Service Mesh and Service Discovery

Consul is used for service mesh and service discovery in this demo project. The MongoDB and dashboard applications are deployed as services in the Consul service mesh, enabling secure communication between them. Consul's service discovery mechanism allows the dashboard application to dynamically discover the MongoDB instance, simplifying configuration and management.

## Repository Structure

- backend.tf: Contains the Terraform backend configuration and provider declarations for Nomad and Vault.
- main.tf: Contains the Terraform resources for deploying MongoDB, the dashboard application, and their respective configurations, including the integration with Vault's MongoDB Secrets Engine and Consul's service mesh and service discovery.
- nomad-jobs/mongodb.hcl: Contains the Nomad job specification for the MongoDB instance, which is registered as a service in the Consul service mesh.
- nomad-jobs/dashboard.hcl: Contains the Nomad job specification for the dashboard application, which is registered as a service in the Consul service mesh and uses Consul's service discovery to connect to the MongoDB instance.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v0.13.0 or newer installed.
- A running [Nomad](https://www.nomadproject.io/downloads) cluster.
- A running [Vault](https://www.vaultproject.io/downloads) server.
- A running [Consul](https://www.consul.io/downloads) cluster.

## Usage

1. Clone this repository:
```
   git clone https://github.com/yourusername/hashistack-demo.git
   cd hashistack-demo
```

2. Initialize the Terraform working directory:
```
   terraform init
```

3. Create a terraform.tfvars file with your Nomad and Vault addresses and tokens:
```
   nomad_addr   = "http://your-nomad-server-address:4646"
   vault_addr   = "http://your-vault-server-address:8200"
   vault_token  = "your-vault-root-token"
```

4. Apply the Terraform configuration:
```
   terraform apply
```

5. After the resources have been created, access the dashboard application at http://your-dashboard-address:3100.

## Cleanup

To destroy the resources created by this demo project, run the following command:
```
terraform apply -destroy
```

## Bonus: Full KVM-based VM with Nomad and Consul

This repository also includes an example of how to schedule a full KVM-based VM using Nomad. The `nomad-jobs/vmdk.hcl` job specification demonstrates this feature. The VM is registered as a service in Consul, allowing its SSH address and port to be discovered through Consul.

To enable this feature, uncomment the following line in the `main.tf` file:

```hcl
#resource "nomad_job" "fullvm" {
#  jobspec = file("${path.module}/nomad-jobs/vmdk.hcl")
#}
```

After applying the Terraform configuration, you can discover the SSH address and port of the deployed VM through Consul. Use the Consul UI or the Consul CLI to query the service information and access the VM using the discovered SSH address and port.

Note that scheduling a full KVM-based VM with Nomad requires additional setup and configuration, such as enabling the QEMU task driver and configuring the required resources. Please consult the Nomad QEMU driver documentation for more details on the necessary setup and configuration.
