#!/bin/bash
# main.sh — Punto de entrada único. Administración de Servidor FTP.

source ./ftp_functions.sh
source ./user_functions.sh
source ./acceso_anonimo.sh

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Este script debe ejecutarse como root (sudo)."
        exit 1
    fi
}

verificar_root

while true; do
    echo ""
    echo "=============================="
    echo "  Administración FTP — Linux"
    echo "=============================="
    echo "1. Instalar y configurar vsftpd"
    echo "2. Crear grupos y estructura base"
    echo "3. Alta masiva de usuarios"
    echo "4. Cambiar usuario de grupo"
    echo "5. Configurar acceso anónimo"
    echo "6. Ver estado del servicio"
    echo "7. Salir"
    echo "=============================="
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1)
            instalar_ftp
            configurar_ftp
            configurar_firewall_ftp
            habilitar_ftp
            ;;
        2)
            crear_grupos
            crear_estructura_base
            ;;
        3)
            alta_masiva_usuarios
            ;;
        4)
            cambiar_grupo_usuario
            ;;
        5)
            configurar_anonimo
            ;;
        6)
            estado_ftp
            ;;
        7)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
done

