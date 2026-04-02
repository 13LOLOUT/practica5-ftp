# User_Functions.ps1 — Gestión de usuarios, grupos y estructura de carpetas FTP en Windows

function New-FTPGroups {
    Write-Host ">>> Creando grupos locales ftp_reprobados y ftp_recursadores..."
    New-LocalGroup -Name "ftp_reprobados" -Description "Grupo FTP reprobados" -ErrorAction SilentlyContinue
    New-LocalGroup -Name "ftp_recursadores" -Description "Grupo FTP recursadores" -ErrorAction SilentlyContinue
    Write-Host ">>> Grupos creados."
}

function New-FTPBaseStructure {
    Write-Host ">>> Creando estructura base de directorios FTP..."
    New-Item -ItemType Directory -Path "C:\ftp\general" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\ftp\grupos\reprobados" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\ftp\grupos\recursadores" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\ftp\usuarios" -Force | Out-Null

    # Archivo de bienvenida en carpeta publica
    Set-Content -Path "C:\ftp\general\bienvenida.txt" -Value "Bienvenido al servidor FTP publico. Solo lectura para anonimos."

    Write-Host ">>> Estructura base creada en C:\ftp\"
}

function New-FTPUser {
    param(
        [string]$Nombre,
        [string]$Password,
        [string]$Grupo
    )

    # Crear usuario local
    $securePass = ConvertTo-SecureString $Password -AsPlainText -Force
    New-LocalUser -Name $Nombre -Password $securePass -PasswordNeverExpires -ErrorAction SilentlyContinue
    Add-LocalGroupMember -Group "ftp_$Grupo" -Member $Nombre -ErrorAction SilentlyContinue

    # Crear estructura de carpetas
    New-Item -ItemType Directory -Path "C:\ftp\usuarios\$Nombre\general" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\ftp\usuarios\$Nombre\$Grupo" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\ftp\usuarios\$Nombre\$Nombre" -Force | Out-Null

    # Permisos NTFS — carpeta personal solo el usuario
    $acl = Get-Acl "C:\ftp\usuarios\$Nombre\$Nombre"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Nombre, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl "C:\ftp\usuarios\$Nombre\$Nombre" $acl

    # Permisos carpeta de grupo
    $aclGrupo = Get-Acl "C:\ftp\usuarios\$Nombre\$Grupo"
    $ruleGrupo = New-Object System.Security.AccessControl.FileSystemAccessRule("ftp_$Grupo", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $aclGrupo.SetAccessRule($ruleGrupo)
    Set-Acl "C:\ftp\usuarios\$Nombre\$Grupo" $aclGrupo

    Write-Host ">>> Usuario '$Nombre' creado en grupo '$Grupo' con estructura FTP lista."
}

function Add-FTPUsersBulk {
    $n = Read-Host "¿Cuántos usuarios deseas crear?"
    for ($i = 1; $i -le $n; $i++) {
        Write-Host "--- Usuario $i de $n ---"
        $uname = Read-Host "  Nombre de usuario"
        $upass = Read-Host "  Contraseña" -AsSecureString
        $upassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($upass))
        $ugrupo = Read-Host "  Grupo (reprobados/recursadores)"
        while ($ugrupo -ne "reprobados" -and $ugrupo -ne "recursadores") {
            $ugrupo = Read-Host "  Grupo inválido. Escribe 'reprobados' o 'recursadores'"
        }
        New-FTPUser -Nombre $uname -Password $upassPlain -Grupo $ugrupo
    }
    Write-Host ">>> Alta masiva completada."
}

function Set-FTPUserGroup {
    $uname = Read-Host "Nombre de usuario a cambiar de grupo"
    $nuevoGrupo = Read-Host "Nuevo grupo (reprobados/recursadores)"
    while ($nuevoGrupo -ne "reprobados" -and $nuevoGrupo -ne "recursadores") {
        $nuevoGrupo = Read-Host "Grupo inválido. Escribe 'reprobados' o 'recursadores'"
    }

    # Detectar grupo anterior
    $grupoAnterior = ""
    if (Get-LocalGroupMember -Group "ftp_reprobados" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$uname" }) {
        $grupoAnterior = "reprobados"
    } else {
        $grupoAnterior = "recursadores"
    }

    Remove-LocalGroupMember -Group "ftp_$grupoAnterior" -Member $uname -ErrorAction SilentlyContinue
    Add-LocalGroupMember -Group "ftp_$nuevoGrupo" -Member $uname -ErrorAction SilentlyContinue

    # Renombrar carpeta de grupo
    $base = "C:\ftp\usuarios\$uname"
    if (Test-Path "$base\$grupoAnterior") {
        Rename-Item -Path "$base\$grupoAnterior" -NewName $nuevoGrupo -ErrorAction SilentlyContinue
    } else {
        New-Item -ItemType Directory -Path "$base\$nuevoGrupo" -Force | Out-Null
    }

    Write-Host ">>> Usuario '$uname' movido de '$grupoAnterior' a '$nuevoGrupo'."
}