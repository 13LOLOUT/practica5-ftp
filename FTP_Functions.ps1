# FTP_Functions.ps1 — Funciones para instalación y configuración de IIS FTP en Windows

function Install-FTPServer {
    Write-Host ">>> Verificando IIS y FTP Service..."
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPServer -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole -NoRestart -ErrorAction SilentlyContinue
    Write-Host ">>> IIS y FTP Service habilitados correctamente."
}

function Enable-FTPServer {
    Write-Host ">>> Iniciando servicio FTPSVC..."
    Start-Service -Name FTPSVC -ErrorAction SilentlyContinue
    Set-Service -Name FTPSVC -StartupType Automatic
    Write-Host ">>> Servicio FTP iniciado y configurado para inicio automático."
}

function Get-FTPStatus {
    Write-Host ">>> Estado del servicio FTP:"
    Get-Service -Name FTPSVC
}

function Set-FTPFirewallRule {
    Write-Host ">>> Configurando reglas de Firewall para FTP (puertos 20 y 21)..."
    New-NetFirewallRule -Name "FTP-Port21" -DisplayName "FTP Server (Port 21)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 21 `
        -ErrorAction SilentlyContinue
    New-NetFirewallRule -Name "FTP-Port20" -DisplayName "FTP Server (Port 20)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 20 `
        -ErrorAction SilentlyContinue
    Write-Host ">>> Reglas de firewall FTP aplicadas."
}