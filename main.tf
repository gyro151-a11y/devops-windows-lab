terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate44914"
    container_name       = "tfstate"
    key                  = "devops-lab.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-lab"
  location = "West US 2"
} # Creates the resource group

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
} # Creates the virtual network

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-devops"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
} # Creates the subnet in the virtual network

resource "azurerm_public_ip" "public_ip" {
  name                = "pip-devops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
} # Creates the virtual public IP in the subnet

resource "azurerm_network_interface" "nic" {
  name                = "nic-devops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
} # Creates the nic with the public IP to attach to a VM

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-devops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"

  admin_username = "azureuser"
  admin_password = "P@ssword1234!"  # temp only (we’ll fix later)

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "/subscriptions/03ffa2fa-c039-4d94-a416-1ae39496cb4e/resourceGroups/rg-devops-images/providers/Microsoft.Compute/images/windows-iis-image"
  } # Creates the vm with the proper parameters


resource "azurerm_virtual_machine_extension" "iis_install" {
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

settings = jsonencode({
  fileUris = [
    "https://raw.githubusercontent.com/gyro151-a11y/devops-windows-lab/main/scripts/install-iis.ps1?${filemd5("scripts/install-iis.ps1")}"
  ]

  commandToExecute = "powershell -ExecutionPolicy Bypass -File install-iis.ps1"
})

  tags = {
    force_update = filemd5("scripts/install-iis.ps1")
  }
} # Installs the iis extension and runs the script to install iis and create a custom webpage

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-devops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
} # Creates the firewall rules to allow rdp and http to the vm

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
} # Associates the firewall to the vm NIC 

#trigger run