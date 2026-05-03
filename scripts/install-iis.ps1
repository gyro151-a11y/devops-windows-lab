Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create a simple webpage
$html = "<h1>Hello from Terraform + Script File</h1>"
$html | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding utf8

Write-Output "IIS installed and page deployed"