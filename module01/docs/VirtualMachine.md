# JHU Production AI - Module 01: Virtual Machine Infrastructure

This module contains Terraform configurations for deploying a Linux virtual machine infrastructure on Microsoft Azure. The infrastructure is designed for educational purposes in the Johns Hopkins University Production AI course.

## PREREQUISITES
- Azure CLI Installed
- Terraform Installed

## Project Organization

```
module01/
├── README.md                           # This documentation file
└── VirtualMachine/                     # Virtual machine deployment directory
    ├── scripts/
    │   └── custom_data.sh              # VM initialization script
    └── terraform/         # Terraform configuration files
        ├── linuxvm.tf                  # Virtual machine resource definitions
        ├── network.tf                  # Networking components (VNet, subnet, NSG, etc.)
        ├── providers.tf                # Azure provider configuration
        ├── resource-group.tf           # Resource group definition
        ├── student.tfvars.json         # Variable values for deployment
        ├── terraform.tfstate           # Terraform state file (managed automatically)
        ├── terraform.tfstate.backup    # Terraform state backup
        └── variables.tf                # Variable declarations
```

## Prerequisites

- VisualStudio Code installed
- Azure subscription with appropriate permissions
- Terraform installed (version >= 1.1.0)
- Azure CLI installed and authenticated

## Terraform Deployment Instructions

### 1. Configure Variables
# Using VisualStudio open the folder to the cloned files

Edit the `VirutalMachine/terraform/student.tfvars.json` file to customize your deployment:

### 2. Deploy Infrastructure

Use terminal in the VisualCode studio

Navigate to the Terraform configuration directory:

$ cd VirtualMachine/terraform


Initialize Terraform:

$ terraform init

Review the deployment plan:

$ terraform plan -var-file="student.tfvars.json"


Apply the configuration:

$ terraform apply -var-file="student.tfvars.json"

Type `yes` when prompted to confirm the deployment.

### 3. Destroy Infrastructure (for your information - keep the VM)

To clean up resources and avoid charges:

$ terraform destroy -var-file="student.tfvars.json"

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
- **Allocation**: Dynamic (IP assigned when VM starts)
- **SKU**: Basic
- **Function**: Enables SSH access from the internet

### 5. Network Security Group (NSG) (`azurerm_network_security_group`)
- **Purpose**: Acts as a virtual firewall controlling network traffic
- **Rules**: 
  - SSH (port 22): Allows inbound SSH connections from any source
  - Priority: 1001
  - Protocol: TCP
- **Function**: Secures network access to the virtual machine

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
- **Size**: Standard_D2s_v3 (2 vCPUs, 8 GB RAM)
- **Operating System**: Ubuntu Server 22.04 LTS
- **Authentication**: Password-based (SSH key authentication disabled)
- **Storage**: Premium SSD with configurable size (default: 128 GB)
- **Initialization**: Runs custom script for software installation

### 9. Custom Data Script (`custom_data.sh`)
- **Purpose**: Automatically configures the VM after deployment
- **Functions**:
  - Updates the system packages
  - Installs Terraform
  - Sets up development tools
  - Configures the user environment
- **Execution**: Runs during VM first boot via cloud-init

## VM Access Information

After successful deployment:

1. **SSH Access**: Use the public IP address displayed in Terraform output
2. **Username**: Value from `studentVMUsername` variable
3. **Password**: Value from `studentVMPassword` variable
4. **Connection Command**: 
   ```bash
   ssh username@public-ip-address
   ```

## Important Notes

- The VM initialization script takes several minutes to complete after deployment
- Check `/var/log/cloud-init-output.log` on the VM for installation progress
- Ensure your Azure subscription has sufficient quota for the VM size
- The public IP is dynamic and may change if the VM is deallocated
- Always destroy resources when not in use to avoid unnecessary charges

## Security Considerations

- Change default passwords before deployment
- Consider using SSH keys instead of passwords for production use
- Review and restrict NSG rules based on your specific requirements
- Monitor Azure costs and set up billing alerts
- Follow principle of least privilege for Azure permissions

## Troubleshooting

- **Terraform Init Issues**: Ensure Azure CLI is authenticated (`az login`)
- **Deployment Failures**: Check Azure subscription limits and permissions
- **SSH Connection Issues**: Verify NSG rules and public IP allocation
- **VM Not Responding**: Check Azure portal for VM status and boot diagnostics