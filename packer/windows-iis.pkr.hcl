packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1.0"
    }
  }
}

source "azure-arm" "windows" {

  managed_image_resource_group_name = "rg-devops-images"
  managed_image_name = "windows-iis-image-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

  location = "westus2"
  vm_size  = "Standard_D2s_v3"

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