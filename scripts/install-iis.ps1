Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create a simple webpage
$html = '<h1>Congratulations! You have a working CI/CD pipeline!</h1>'
$html | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding utf8

iisreset