
resource "azurerm_network_interface" "student-nic" {
  name                = var.studentNICName
  location            = azurerm_resource_group.studentRG.location
  resource_group_name = azurerm_resource_group.studentRG.name

  ip_configuration {
    name                          = "student_configuration"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.student-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "associate-nsg-nic" {
  network_interface_id      = azurerm_network_interface.student-nic.id
  network_security_group_id = azurerm_network_security_group.student-nsg.id
}

resource "azurerm_linux_virtual_machine" "student-vm" {
  name                  = var.studentVMName
  location              = azurerm_resource_group.studentRG.location
  resource_group_name   = azurerm_resource_group.studentRG.name
  network_interface_ids = [azurerm_network_interface.student-nic.id]
  size                  = "Standard_D2s_v3"
	disable_password_authentication = false

  os_disk {
    name                 = var.studentVMDiskName
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.diskSizeGB
  }
  custom_data = base64encode(templatefile("../scripts/custom_data.sh", {
    user_home_dir = "/home/${var.studentVMUsername}"
  }))
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  computer_name  = "hostname"
  admin_username = var.studentVMUsername
  admin_password = var.studentVMPassword
}