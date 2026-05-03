Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create a simple webpage
$html = '<h1>Hurray! This is the second run in a row with no issues!</h1>'
$html | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding utf8

iisreset