# FTP_Site.ps1 — Configuración del sitio FTP en IIS con acceso anónimo y autenticado

function New-FTPSite {
    Write-Host ">>> Configurando sitio FTP en IIS..."

    Import-Module WebAdministration -ErrorAction SilentlyContinue

    # Eliminar sitio FTP anterior si existe
    Remove-WebSite -Name "PracticaFTP" -ErrorAction SilentlyContinue

    # Crear nuevo sitio FTP
    New-WebFtpSite -Name "PracticaFTP" -Port 21 -PhysicalPath "C:\ftp" -Force

    # Habilitar autenticación anónima
    Set-ItemProperty "IIS:\Sites\PracticaFTP" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true

    # Habilitar autenticación básica
    Set-ItemProperty "IIS:\Sites\PracticaFTP" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true

    # Permitir SSL solo si hay certificado, si no usar allowSsl
    Set-ItemProperty "IIS:\Sites\PracticaFTP" -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslAllow"
    Set-ItemProperty "IIS:\Sites\PracticaFTP" -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslAllow"

    # Autorización anónima — solo lectura
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{
        accessType  = "Allow"
        users       = ""
        roles       = ""
        permissions = "Read"
    } -PSPath "IIS:\" -Location "PracticaFTP" -ErrorAction SilentlyContinue

    # Autorización usuarios autenticados — lectura y escritura
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{
        accessType  = "Allow"
        users       = "*"
        roles       = ""
        permissions = "Read, Write"
    } -PSPath "IIS:\" -Location "PracticaFTP" -ErrorAction SilentlyContinue

    # Habilitar aislamiento de usuarios
    Set-ItemProperty "IIS:\Sites\PracticaFTP" -Name ftpServer.userIsolation.mode -Value "IsolateAllDirectories"

    Write-Host ">>> Sitio FTP 'PracticaFTP' configurado correctamente."

    # Reiniciar servicio FTP
    Restart-Service FTPSVC
    Write-Host ">>> Servicio FTP reiniciado."
}