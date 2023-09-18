### Retrieve and Install Require Package Managers ###
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force


Install-WindowsFeature -Name RSAT-AD-Tools, RSAT-DNS-Server, RSAT-File-Services

Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter F -FriendlyName 'Data Disk'

Set-TimeZone -Id "W. Europe Standard Time"

choco install microsoftazurestorageexplorer -y
choco install az.powershell -y
choco install azcopy10 -y
choco install azure-cli -y
choco install powershell-core -y
choco install 7zip -y
