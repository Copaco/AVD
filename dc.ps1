Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter F -FriendlyName 'AD'

Set-TimeZone -Id "W. Europe Standard Time"

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-WindowsFeature -Name DNS -IncludeManagementTools

Reboot-Computer 
