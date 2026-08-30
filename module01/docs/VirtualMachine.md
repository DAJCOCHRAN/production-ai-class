# JHU Production AI - Module 01: Virtual Machine Infrastructure

This module contains Terraform configurations for deploying a Linux virtual machine infrastructure on Microsoft Azure. The infrastructure is designed for educational purposes in the Johns Hopkins University Production AI course.

## Prerequisites

The tool installs, the SSH key you have to generate, and the subscription ID you have to fill
in are all in the [module README](../README.md). Do that first. In particular, **the
deployment will not run until `studentSubscriptionId` in `student.tfvars.json` holds the
course subscription ID from the Module 0 Azure Subscription page on Canvas.**

## Project Organization

```
module01/
├── README.md                           # Prerequisites, SSH key, subscription setup
├── docs/
│   ├── VirtualMachine.md               # This documentation file
│   └── VSCodeSetup.md                  # Connecting VS Code to the VM
└── VirtualMachine/                     # Virtual machine deployment directory
    ├── scripts/
    │   └── custom_data.sh              # VM initialization script (cloud-init)
    └── terraform/                      # Terraform configuration files
        ├── linuxvm.tf                  # Virtual machine and NIC resource definitions
        ├── network.tf                  # Networking components (VNet, subnet, NSG, public IP)
        ├── outputs.tf                  # Public IP, SSH command, resource group
        ├── providers.tf                # Azure provider configuration
        ├── resource-group.tf           # Resource group definition
        ├── student.tfvars.json         # Variable values for deployment - you edit this
        ├── variables.tf                # Variable declarations
        ├── terraform.tfstate           # Terraform state file (managed automatically)
        └── terraform.tfstate.backup    # Terraform state backup
```

## Terraform Deployment Instructions

### 1. Configure Variables

Open the cloned folder in Visual Studio Code and edit
`VirtualMachine/terraform/student.tfvars.json`:

| Variable | What to set it to |
|---|---|
| `studentSubscriptionId` | The course subscription ID, from the Module 0 Azure Subscription page. See the [module README](../README.md#your-azure-subscription). |
| `studentRGName` and every other `student*Name` | Replace `example` with your own name. Names must be unique in the shared subscription. |
| `studentVMUsername` | Leave as `azureuser` unless you have a reason to change it. |

**Terraform will refuse to plan until you have done both.** The variables are validated, so a
subscription ID left as the placeholder, or a resource name still containing `example`, stops
the deployment with a message naming the exact variable and the line in `student.tfvars.json`.
This is deliberate: the subscription is shared with the whole class, and a resource nobody can
attribute is a resource nobody will clean up. Terraform reports every offending variable at
once, so you can fix them in a single pass.

These variables are declared in `variables.tf` and already have sensible defaults, so they
are not in `student.tfvars.json` unless you want to override one:

| Variable | Default | Purpose |
|---|---|---|
| `studentLocation` | `East US` | Azure region for every resource. |
| `studentVMSize` | `Standard_D4s_v3` | 4 vCPU / 16 GB. The course subscription has no GPU SKUs, so this is a CPU machine all semester. |
| `sshPublicKeyPath` | `~/.ssh/azure_lab.pub` | The public key installed on the VM. |
| `allowedSSHSource` | `*` | Source IP or CIDR allowed to reach port 22. Narrow it to your own address if you can. |
| `diskSizeGB` | `128` | OS disk size in GB. |

### 2. Deploy Infrastructure

Use the terminal in Visual Studio Code.

Navigate to the Terraform configuration directory:

    $ cd VirtualMachine/terraform

Initialize Terraform:

    $ terraform init

Review the deployment plan:

    $ terraform plan -var-file="student.tfvars.json"

Apply the configuration:

    $ terraform apply -var-file="student.tfvars.json"

Type `yes` when prompted to confirm the deployment.

When it finishes, Terraform prints your VM's public IP and a ready-to-paste SSH command.
Save both, you need them for [VS Code setup](./VSCodeSetup.md).

### 3. Destroy Infrastructure (for your information - keep the VM)

To clean up resources and avoid charges:

    $ terraform destroy -var-file="student.tfvars.json"

**Do not destroy this VM during the semester.** It is your development machine for the whole
course, and rebuilding it costs you another provisioning cycle. To stop paying for compute
between sessions, deallocate it instead:

    $ az vm deallocate --resource-group <your-rg> --name <your-vm>
    $ az vm start      --resource-group <your-rg> --name <your-vm>

## Azure Components Deployed

### 1. Resource Group (`azurerm_resource_group`)
- **Purpose**: Logical container that holds related Azure resources
- **Configuration**: Single resource group to organize all VM-related resources
- **Location**: Configurable via `studentLocation` variable (defaults to "East US")

### 2. Virtual Network (VNet) (`azurerm_virtual_network`)
- **Purpose**: Provides isolated network environment for Azure resources
- **Address Space**: 10.0.0.0/16 (65,536 IP addresses)
- **Function**: Enables secure communication between Azure resources

### 3. Subnet (`azurerm_subnet`)
- **Purpose**: Subdivides the virtual network for better organization and security
- **Address Range**: 10.0.1.0/24 (256 IP addresses)
- **Name**: "vmSubnet"
- **Function**: Hosts the virtual machine and its network interface

### 4. Public IP Address (`azurerm_public_ip`)
- **Purpose**: Provides internet connectivity to the virtual machine
- **SKU**: Standard. Basic SKU public IPs were retired on 30 September 2025 and can no longer be created.
- **Allocation**: Static, which Standard SKU requires. The IP survives a deallocate, so your `~/.ssh/config` keeps working between sessions.
- **Function**: Enables SSH access from the internet

### 5. Network Security Group (NSG) (`azurerm_network_security_group`)
- **Purpose**: Acts as a virtual firewall controlling network traffic
- **Rules**:
  - SSH (port 22) inbound, priority 1001, TCP
  - Source is the `allowedSSHSource` variable, which defaults to `*` so the VM stays reachable from campus, home, and other networks
- **Function**: Port 22 is the only way in. What makes an internet-facing SSH port acceptable is that authentication is key-only, see below.

### 6. Network Interface (`azurerm_network_interface`)
- **Purpose**: Connects the virtual machine to the virtual network
- **Configuration**:
  - Dynamic private IP allocation
  - Associated with public IP and subnet
- **Function**: Handles network communication for the VM

### 7. Network Interface Security Group Association
- **Purpose**: Links the network security group to the network interface
- **Function**: Applies firewall rules to the VM's network traffic

### 8. Linux Virtual Machine (`azurerm_linux_virtual_machine`)
- **Size**: Standard_D4s_v3 (4 vCPUs, 16 GB RAM). The AI stack does not fit comfortably in 8 GB. The course subscription has no GPU SKUs, so this is a CPU machine for the whole semester and the CPU builds of PyTorch and TensorFlow are what is installed.
- **Operating System**: Ubuntu Server 22.04 LTS (gen2)
- **Authentication**: SSH public key only. Password authentication is disabled.
- **Storage**: Premium SSD, size set by `diskSizeGB` (default 128 GB)
- **Initialization**: Runs `custom_data.sh` at first boot to install the toolchain

### 9. Custom Data Script (`custom_data.sh`)
- **Purpose**: Installs the entire course toolchain at first boot, so nobody installs anything by hand
- **Installs**:
  - Base packages, and Python 3.12 alongside the system Python
  - A `~/ai-dev` virtual environment that auto-activates on login
  - The AI/ML stack: PyTorch, TensorFlow, scikit-learn, transformers, datasets, LangChain, the Anthropic and OpenAI clients, MLflow, Weights and Biases, DVC, and the usual data science libraries
  - Azure CLI and Azure Functions Core Tools
  - Docker (Module 08), and kubectl, Helm, Terraform and Node (Modules 09+)
- **Execution**: Runs once, as root, during first boot via cloud-init
- **Result**: Writes a pass/fail summary to `/var/log/provision-summary.txt` and freezes the environment to `~/requirements.txt`

## VM Access Information

After a successful deployment, Terraform prints:

- `public_ip` - the VM's public IP address
- `ssh_command` - a ready-to-paste SSH command
- `resource_group` - the resource group holding every resource in this deployment

Connect with your private key:

```bash
ssh -i ~/.ssh/azure_lab azureuser@<public-ip-address>
```

There is no password. If you are prompted for one, SSH did not find your key, check the `-i`
path and that it matches the `sshPublicKeyPath` you deployed with.

## Important Notes

- **The VM is not ready when `terraform apply` finishes.** The machine exists, but the toolchain installs in the background for a further 15-25 minutes.
- Watch it with `sudo tail -f /var/log/cloud-init-output.log`, or block until it is done with `cloud-init status --wait`
- When it reports `status: done`, read `cat /var/log/provision-summary.txt` and check nothing says FAIL
- Docker without `sudo` takes effect on your **next** login, not the one where the install finished
- Ensure your Azure subscription has sufficient quota for the VM size
- Always deallocate the VM when not in use to avoid unnecessary charges

## Security Considerations

- Authentication is SSH-key-only by design. Do not re-enable password authentication.
- Your private key (`~/.ssh/azure_lab`) never leaves your local machine and is never committed.
- Narrow `allowedSSHSource` from `*` to your own IP or CIDR if your address is stable.
- Never commit API keys. Put them in a `.env` file that git ignores.
- Monitor Azure costs and set up billing alerts
- Follow principle of least privilege for Azure permissions

## Troubleshooting

- **`still contains 'example'`**: you have not put your own name into every resource name in `student.tfvars.json`. The message names the variable.
- **`studentSubscriptionId is still the placeholder`**: fill in the course subscription ID, see the [module README](../README.md#your-azure-subscription)
- **`No SSH public key was found at sshPublicKeyPath`**: you have not generated the key pair yet, see the [module README](../README.md#prerequisites)
- **Terraform Init Issues**: Ensure Azure CLI is authenticated (`az login`)
- **Deployment lands in the wrong subscription**: check `studentSubscriptionId` in `student.tfvars.json` against the Module 0 Azure Subscription page, and `az account show`
- **Deployment Failures**: Check Azure subscription limits and permissions
- **SSH Connection Issues**: Verify NSG rules, the public IP, and that you passed `-i ~/.ssh/azure_lab`
- **A tool reports "not found" after provisioning**: check `/var/log/provision-summary.txt` and `/var/log/cloud-init-output.log`
- **VM Not Responding**: Check Azure portal for VM status and boot diagnostics
