output "public_ip" {
  value       = azurerm_public_ip.student-public-ip.ip_address
  description = "VM public IP address"
}

output "ssh_command" {
  value       = "ssh -i ${replace(var.sshPublicKeyPath, ".pub", "")} ${var.studentVMUsername}@${azurerm_public_ip.student-public-ip.ip_address}"
  description = "Ready-to-paste SSH command"
}

output "resource_group" {
  value       = azurerm_resource_group.studentRG.name
  description = "Resource group holding every resource in this deployment"
}

output "provisioning_note" {
  value       = "Tools install in the background for 15-25 minutes after this completes. Run 'cloud-init status --wait' on the VM, then 'cat /var/log/provision-summary.txt'."
  description = "Reminder that the VM is not ready the instant Terraform finishes"
}
