<#
        .SYNOPSIS
        Adds a file name extension to a supplied name.

        .DESCRIPTION
        Adds a file name extension to a supplied name.
        Takes any strings for the file name or extension.

        .PARAMETER Name
        Specifies the file name.
            PatchType = waar moet de aanpassing gedaan worden

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>




## notes

<#
script netjes maken

optimalisaties



#>
######################
#    AVD Variables   #
######################

$erroractionpreference          = 'silentlycontinue'
$logfile                        = "c:\temp\AVDinstallation.log"
$LocalAVDPath                   = "c:\temp\avd"
$ODTpath                        = "c:\temp\avd\ODT"
$Unattendedxmluri               = "https://raw.githubusercontent.com/Copaco/AVD/main/M365-AppsForBusiness.xml"
#$Unattendedxml                  = "C:\temp\avd\CopacoM365Business-64.xml" #path to office xml 
$languagePacks                  = "en-US", "nl-NL"
$defaultLanguage                = "nl-NL"
$TeamsURI                       = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
$TeamWebSocket                  = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt'
$OneDriveURI                    = 'https://go.microsoft.com/fwlink/?linkid=844652'
$FslogixProfilePath             = '\\placeholder\fslogix'
$TimeZone                       = "W. Europe Standard Time"





##############################
#    AVD Script Functions    #
##############################

#download latest M365 apps
function Get-ODTUri {
    <#
        .SYNOPSIS
            Get Download URL of latest Office 365 Deployment Tool (ODT).
        .NOTES
        
        .LINK
           
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $url = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117"
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to ODT: $url with error $_."
        Break
    }
    finally {
        $ODTUri = $response.links | Where-Object { $_.outerHTML -like "*click here to download manually*" }
        Write-Output $ODTUri.href
    }
}

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter()]
        [System.Int32]
        $Level = 0
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $indentation = '  ' * $Level
    $output = "[{0}] - {1}{2}" -f $timestamp, $indentation, $Message
    Write-Host  $output
}

####################################
#    Test/Create Temp Directory    #
####################################
if ((Test-Path c:\temp) -eq $false) {
    Write-Log "Creating C:\temp"
    New-Item -Path c:\temp -ItemType Directory
}
else {
    Write-Log "C:\temp Already Exists"
}
if ((Test-Path $LocalAVDPath) -eq $false) {
    Write-Log "Creating C:\temp\avd"
    New-Item -Path $LocalAVDPath -ItemType Directory
}
else {
    Write-Log "C:\temp\avd Already Exists"
}

if ((Test-Path $ODTpath) -eq $false) {
    Write-Log "Creating C:\temp\avd\ODT Directory"
    New-Item -Path $ODTpath -ItemType Directory
}
else {
    Write-Log  "C:\temp\avd\ODT Already Exists"
}

Start-Transcript -Path $logfile -Force

#################################
#    Download AVD Componants    #
#################################

Write-Log "Downloading Teams"
Invoke-WebRequest -Uri $TeamsURI -OutFile "$LocalAVDPath\Teams.msi"

Write-Log "Downloading Teams WebSocket"
Invoke-WebRequest -Uri $TeamWebSocket -OutFile "$LocalAVDPath\TeamsWebSocket.msi"

Write-Log "Downloading OneDrive"
Invoke-WebRequest -Uri $OneDriveURI -OutFile "$LocalAVDPath\OneDrive.exe"
 

#########################
#    FSLogix Configuration#
# zie oa https://learn.microsoft.com/en-us/fslogix/tutorial-configure-profile-containers#profile-container-configuration
# 
#########################
Write-Log "Configuring FSLogix Profile Settings"
Push-Location 
Set-Location HKLM:\SOFTWARE\
New-Item `
    -Path HKLM:\SOFTWARE\FSLogix `
    -Name Profiles `
    -Value "" `
    -Force `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "Enabled" `
    -Type "Dword" `
    -Value "1" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "DeleteLocalProfileWhenVHDShouldApply" `
    -Type "Dword" `
    -Value "1" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "IsDynamic" `
    -Type "Dword" `
    -Value "1" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "KeepLocalDir" `
    -Type "Dword" `
    -Value "0" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "KeepLocalDir" `
    -Type "Dword" `
    -Value "0" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "ProfileType" `
    -Type "Dword" `
    -Value "0" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "SetTempToLocalPath" `
    -Type "Dword" `
    -Value "3" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "SizeInMBs" `
    -Type "Dword" `
    -Value "30000" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "VHDLocations" `
    -Type String `
    -Value $FslogixProfilePath `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "VHDNameMatch" `
    -Type String `
    -Value "%userdomain%-%username%" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "VHDNamePattern" `
    -Type String `
    -Value "%userdomain%-%username%" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "VolumeType" `
    -Type String `
    -Value "VHDX" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "FlipFlopProfileDirectoryName" `
    -Type "Dword" `
    -Value "1" `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "LockedRetryCount" `
    -Type "Dword" `
    -Value "3"  `
    -Verbose
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "LockedRetryInterval" `
    -Type "Dword" `
    -Value "15" `
    -Verbose
Pop-Location

#########################
#    M365 Apps          #
#########################

#download ODT 
$URL = $(Get-ODTUri)
Write-Log "Downloading latest version Office 365 Deployment Tool"
Set-Location $ODTpath
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile .\officedeploymenttool.exe
Write-Log  "Downloaded latest version Office 365 Deployment Tool"

#extract ODT
$Version = (Get-Command .\officedeploymenttool.exe).FileVersionInfo.FileVersion

.\officedeploymenttool.exe /quiet /extract:.\$Version
start-sleep -s 5 -Verbose

#Installing Office
Set-Location .\$Version


$Unattendedxml = "C:\temp\avd\M365apps4business.xml"
Invoke-WebRequest -Uri $Unattendedxmluri -OutFile $Unattendedxml -UseBasicParsing

$ODTDownload = "/download $Unattendedxml"
$ODTInstallation = "/configure $Unattendedxml"


try {
    Write-Log  "Downloading installation files installation M365 Apps"
    $DownloadExitCode = (Start-Process -FilePath setup.exe -ArgumentList $ODTDownload -Wait -PassThru).ExitCode
}
catch {
    Write-Log "Failed to download M365 Apps"
}
if ($DownloadExitCode -eq 0) {
    Write-Log "Sucessfully Downloaded M365 Apps"
}
else {
    Write-Log  $logfile "Error during download of"
}

try {
    Write-Log  "Starting with installation of M365 Apps"
    $InstallExitCode = (Start-Process -FilePath .\setup.exe -ArgumentList $ODTInstallation -Wait -PassThru).ExitCode
}
catch {
    Write-Log  "Failed to install M365 Apps"
}
if ($InstallExitCode -eq 0) {
    Write-Log  "Sucessfully installed M365 Apps"
}
else {
    Write-Log  "Error during download of"
}


start-sleep -s 10 -Verbose

Set-Location $LocalAVDpath -Verbose

#########################
#    Teams  w optimalization#
# https://learn.microsoft.com/en-us/azure/virtual-desktop/teams-on-avd
#########################

Write-Log "Starting with the installation of MS Teams"
# set required registry
$testRegistry = Test-Path 'HKLM:\SOFTWARE\Microsoft\Teams'


if ($testRegistry -eq $false) {
    try {
        New-Item -Path 'HKLM:\SOFTWARE\Microsoft\' -Name Teams
        New-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Teams' -Name "IsWVDEnvironment" -Value 1 -PropertyType "DWORD" -Force
        Write-Log  "Added AVD Registry Key"
    }
    catch {
        Write-Log "Unable to set Team AVD Registry Key"
    }
}
else {
    Write-Log "AVD Registry Key Already present"
}

#Teams Audio Optimalization
$TeamsWebSocketArugment = '/q'
$TeamsWebSocketInstaller = "$LocalAVDPath\TeamsWebSocket.msi"

try {
    $TeamsWebSocketInstallationOutput = Start-Process -FilePath $TeamsWebSocketInstaller -ArgumentList $TeamsWebSocketArugment -Wait -PassThru
    Write-Log  "Successfully installed Teams Websocket"
}
catch {
    Write-Log  "Unsuccessfully installed Teams Websocket"
    Write-Log "$TeamsWebSocketInstallationOutput"

}

#start installation Teams
$TeamsinstallArguments = 'OPTIONS="noAutoStart=true" ALLUSERS=1'
$Teamsinstaller = "$LocalAVDPath\teams.msi"

try {
    $TeamsInstallationOutput = Start-Process -FilePath $Teamsinstaller -ArgumentList $TeamsinstallArguments -Wait -PassThru
    Write-Log  "Successfully installed Teams"
}
catch {
    Write-Log  "Unsuccessfully installed Teams"
    Write-Log  "$TeamsInstallationOutput"
}


#########################
#    Onedrive           #
#########################
Write-Log "Starting with the installation of OneDrive"
#Start installation OneDrive
$OneDriveArguments = "/ALLUSERS"
$OndriveInstaller = "$LocalAVDpath\OneDrive.exe"

try {
    $OneDriveInstallationOutput = Start-Process -FilePath $OndriveInstaller -ArgumentList $OneDriveArguments 
    Write-Log  "Successfully installed OneDrive"
}
catch {
    Write-Log  "Unsuccessfully installed OneDrive"
    Write-Log  "$OneDriveInstallationOutput"
}

Start-Sleep -Seconds 120 -Verbose

######################
#    Language Pack   #
######################

Write-Log "Installing language pack"

Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup" 

# Download and install the Language Packs
foreach ($language in $languagePacks) {
    Write-Log  "Installing Language Pack for: $($language)"
    Install-Language $language
    Write-Log  "Installing Language Pack for: $($language) completed."
}

if ($defaultLanguage -eq $null) {
    Write-Log t "Default Language not configured."
}
else {
    Write-Log  "Setting default Language to: $($defaultLanguage)"
    Set-SystemPreferredUILanguage $defaultLanguage
}



<# Notes:

This Scripted Action will install the multimedia redirection extension for virtual desktop, along 
with the browser extension.

See https://learn.microsoft.com/en-us/azure/virtual-desktop/multimedia-redirection
for more information

#>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Write-Log "Downloading C++ redistributables"
Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile "$env:TEMP\vc_redist.x64.exe"
Write-Log "Installing C++ redistributables"
Start-Process -NoNewWindow -FilePath "$env:TEMP\vc_redist.x64.exe" -ArgumentList "/q /norestart" -Wait

Write-Log "Downloading multimedia redirection msi"
Invoke-WebRequest -Uri 'https://aka.ms/avdmmr/msi' -OutFile "$env:TEMP\MsMMRHostInstaller.msi"
Write-Log "Installing multimedia redirection"
Start-Process msiexec.exe -Wait -ArgumentList "/I $env:TEMP\MsMMRHostInstaller.msi /quiet"


### deploy latest updates

<#
Notes:
This script will install ALL Windows updates using PSWindowsUpdate
See: https://www.powershellgallery.com/packages/PSWindowsUpdate for details on
how to customize and use the module for your needs.
#>

# Ensure PSWindowsUpdate is installed on the system.
Write-Log "Getting latest updates"

if (!(Get-installedmodule PSWindowsUpdate)) {

    # Ensure NuGet and PowershellGet are installed on system
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PowershellGet -Force

    # Install latest version of PSWindowsUpdate
    Install-Module PSWindowsUpdate -Force
}
Import-Module PSWindowsUpdate -Force

# Initiate download and install of all pending Windows updates
Install-WindowsUpdate -AcceptAll -ForceInstall -IgnoreReboot

##Setting time zone
Write-log "Setting time zone to $($TimeZone)"
Set-TimeZone -id $TimeZone -Verbose

#########################
#    CleanUP           #
#########################

# Clean up buildArtifacts directory
#Remove-Item -Path "C:\buildArtifacts\*" -Force -Recurse

# Delete the buildArtifacts directory
#Remove-Item -Path "C:\buildArtifacts" -Force

# Clean up temp directory
Remove-Item -Path "C:\temp\avd\*" -Force -Recurse -Verbose

Write-Log  "Finished installing all components"


Write-Log "stopping transcript and rebooting machine"
Stop-Transcript 

Restart-Computer

#return 0
