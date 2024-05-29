If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run the script as administrator."
    Exit 1
}

$MANAGER = ""
$GROUP = "desktop,default"
$WazuhAgentUrl = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.2-1.msi"
$WazuhAgentInstaller = "C:\Windows\Temp\wazuh-agent-4.7.2-1.msi"
$InternalConfigFile = "C:\Program Files (x86)\ossec-agent\local_internal_options.conf"

# Invoke-WebRequest -Uri $WazuhAgentUrl -OutFile $WazuhAgentInstaller

if (!$MANAGER) {
    Write-Error "You need to set value for 'MANAGER' before executing the script." -ErrorAction Stop
}

try {
    Invoke-WebRequest -Uri $WazuhAgentUrl -OutFile $WazuhAgentInstaller
}
catch {
    Write-Output "Unable to download the MSI file."
    Write-Error $_ -ErrorAction Stop
}

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$WazuhAgentInstaller`" WAZUH_MANAGER=$MANAGER WAZUH_AGENT_GROUP=$GROUP /quiet" -Wait

Add-Content -Path $InternalConfigFile -Value "sca.remote_commands=1"

Start-Service -Name "WazuhSvc"
Set-Service -Name "WazuhSvc" -StartupType Automatic

Write-Output "Wazuh agent installation and configuration completed successfully."
