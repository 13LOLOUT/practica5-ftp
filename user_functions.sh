#!/bin/bash
# user_functions.sh — Gestión de usuarios, grupos y estructura de carpetas FTP

crear_estructura_base() {
    echo ">>> Creando estructura base de directorios FTP..."
    mkdir -p /srv/ftp/general
    mkdir -p /srv/ftp/grupos/reprobados
    mkdir -p /srv/ftp/grupos/recursadores
    mkdir -p /srv/ftp/usuarios

    chown root:root /srv/ftp/general
    chmod 755 /srv/ftp/general

    chown root:ftp_reprobados /srv/ftp/grupos/reprobados
    chmod 775 /srv/ftp/grupos/reprobados

    chown root:ftp_recursadores /srv/ftp/grupos/recursadores
    chmod 775 /srv/ftp/grupos/recursadores

    echo ">>> Estructura base creada en /srv/ftp/"
}

crear_grupos() {
    echo ">>> Creando grupos ftp_reprobados y ftp_recursadores..."
    groupadd -f ftp_reprobados
    groupadd -f ftp_recursadores
    echo ">>> Grupos creados."
}

crear_usuario() {
    local nombre=$1
    local password=$2
    local grupo=$3

    useradd -m -s /bin/false -G ftp_${grupo} "$nombre" 2>/dev/null || true
    echo "${nombre}:${password}" | chpasswd

    grep -qxF "$nombre" /etc/vsftpd.userlist 2>/dev/null || echo "$nombre" >> /etc/vsftpd.userlist

    local base="/srv/ftp/usuarios/${nombre}"
    mkdir -p "${base}/general"
    mkdir -p "${base}/${grupo}"
    mkdir -p "${base}/${nombre}"

    chown root:root "$base"
    chmod 755 "$base"

    chown "${nombre}:${nombre}" "${base}/general"
    chmod 755 "${base}/general"

    chown "${nombre}:ftp_${grupo}" "${base}/${grupo}"
    chmod 775 "${base}/${grupo}"

    chown "${nombre}:${nombre}" "${base}/${nombre}"
    chmod 700 "${base}/${nombre}"

    echo ">>> Usuario '$nombre' creado en grupo '$grupo' con estructura FTP lista."
}

alta_masiva_usuarios() {
    read -p "¿Cuántos usuarios deseas crear? " n
    for (( i=1; i<=n; i++ )); do
        echo "--- Usuario $i de $n ---"
        read -p "  Nombre de usuario: " uname
        read -s -p "  Contraseña: " upass
        echo ""
        read -p "  Grupo (reprobados/recursadores): " ugrupo
        while [[ "$ugrupo" != "reprobados" && "$ugrupo" != "recursadores" ]]; do
            read -p "  Grupo inválido. Escribe 'reprobados' o 'recursadores': " ugrupo
        done
        crear_usuario "$uname" "$upass" "$ugrupo"
    done
    systemctl restart vsftpd
    echo ">>> Alta masiva completada. vsftpd reiniciado."
}

cambiar_grupo_usuario() {
    read -p "Nombre de usuario a cambiar de grupo: " uname
    read -p "Nuevo grupo (reprobados/recursadores): " nuevo_grupo
    while [[ "$nuevo_grupo" != "reprobados" && "$nuevo_grupo" != "recursadores" ]]; do
        read -p "Grupo inválido. Escribe 'reprobados' o 'recursadores': " nuevo_grupo
    done

    local grupo_anterior
    if id -nG "$uname" | grep -qw "ftp_reprobados"; then
        grupo_anterior="reprobados"
    else
        grupo_anterior="recursadores"
    fi

    usermod -g ftp_${nuevo_grupo} "$uname"
    gpasswd -d "$uname" ftp_${grupo_anterior} 2>/dev/null || true
    usermod -aG ftp_${nuevo_grupo} "$uname"

    local base="/srv/ftp/usuarios/${uname}"
    mv "${base}/${grupo_anterior}" "${base}/${nuevo_grupo}" 2>/dev/null || mkdir -p "${base}/${nuevo_grupo}"
    chown "${uname}:ftp_${nuevo_grupo}" "${base}/${nuevo_grupo}"
    chmod 775 "${base}/${nuevo_grupo}"

    systemctl restart vsftpd
    echo ">>> Usuario '$uname' movido de '$grupo_anterior' a '$nuevo_grupo'."
}
