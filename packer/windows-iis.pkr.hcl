packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1.0"
    }
  }
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}


source "azure-arm" "windows" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  managed_image_resource_group_name = "rg-devops-images"
  managed_image_name = "windows-iis-image-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

  location = "westus2"
  vm_size  = "Standard_D2s_v3"

  virtual_network_name                = "vnet-platform"
  virtual_network_subnet_name         = "devops"
  virtual_network_resource_group_name = "rg-devops-platform"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

  communicator    = "winrm"
  winrm_use_ssl   = true
  winrm_insecure  = true
  winrm_timeout   = "5m"

  azure_tags = {
    environment = "dev"
    created_by  = "packer"
  }
}

build {
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    script = "scripts/install-iis.ps1"
  }

  provisioner "powershell" {
    inline = [
      "Write-Output 'Running Sysprep...'",
      "Start-Process -FilePath C:\\Windows\\System32\\Sysprep\\Sysprep.exe -ArgumentList '/oobe /generalize /shutdown /quiet' -Wait"
    ]
  }

  post-processor "manifest" {
    output = "packer-manifest.json"
  }
}