Install-WindowsFeature -Name RSAT-AD-Tools, RSAT-DNS-Server, RSAT-File-Services

Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter F -FriendlyName 'Data Disk'

Set-TimeZone -Id "W. Europe Standard Time"
