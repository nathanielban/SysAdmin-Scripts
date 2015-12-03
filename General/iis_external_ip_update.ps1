$DYNDNSHOST = "contoso.com"
$IISSITE = "contoso"
Import-Module WebAdministration
$ip=[System.Net.Dns]::GetHostAddresses("$DYNDNSHOST")| Select-Object -ExpandProperty IPAddressToString
Set-WebConfigurationProperty -filter "/system.applicationHost/sites/siteDefaults/ftpServer/firewallSupport" -name externalIp4Address -value $ip
