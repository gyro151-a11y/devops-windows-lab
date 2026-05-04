Install-WindowsFeature -Name Web-Server -IncludeManagementTools

$html = '<h1>Pipeline Test - Version X</h1>'

Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $html -Force

iisreset