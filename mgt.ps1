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


#download avd admin
$avddminurl = "https://blog.itprocloud.de/assets/files/WVDAdmin.msi"

if ((Test-Path c:\temp) -eq $false) {

    New-Item -Path c:\temp -ItemType Directory
}
else {
    write-host "C:\temp Already Exists"
}

Invoke-WebRequest -Uri $avddminurl -OutFile "C:\Temp\AVDadmin.msi"

$AVDAdminArugment = '/q'
$AVDAdminInstaller = "C:\Temp\AVDadmin.msi"

Start-Process -FilePath $AVDAdminInstaller -ArgumentList $AVDAdminArugment -Wait -PassThru
