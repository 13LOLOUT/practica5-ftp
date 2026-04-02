. .\FTP_Functions.ps1
. .\User_Functions.ps1
. .\FTP_Site.ps1

while ($true) {
    Write-Host ""
    Write-Host "=============================="
    Write-Host "  Administracion FTP - Windows"
    Write-Host "=============================="
    Write-Host "1. Instalar y configurar IIS FTP"
    Write-Host "2. Crear grupos y estructura base"
    Write-Host "3. Alta masiva de usuarios"
    Write-Host "4. Cambiar usuario de grupo"
    Write-Host "5. Configurar sitio FTP en IIS"
    Write-Host "6. Ver estado del servicio"
    Write-Host "7. Salir"
    Write-Host "=============================="
    $opcion = Read-Host "Selecciona una opcion"

    switch ($opcion) {
        '1' { Install-FTPServer; Enable-FTPServer; Set-FTPFirewallRule }
        '2' { New-FTPGroups; New-FTPBaseStructure }
        '3' { Add-FTPUsersBulk }
        '4' { Set-FTPUserGroup }
        '5' { New-FTPSite }
        '6' { Get-FTPStatus }
        '7' { Write-Host "Saliendo..."; exit }
        default { Write-Host "Opcion no valida." }
    }
}
