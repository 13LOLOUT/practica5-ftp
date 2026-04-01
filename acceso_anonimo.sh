#!/bin/bash
# acceso_anonimo.sh — Configuración del acceso FTP anónimo de solo lectura

configurar_anonimo() {
    echo ">>> Configurando acceso anónimo a /srv/ftp/general..."

    cat > /srv/ftp/general/bienvenida.txt << 'EOF'
Bienvenido al servidor FTP público.
Acceso de solo lectura. Para subir archivos inicia sesión con tu cuenta.
EOF

    chown -R ftp:ftp /srv/ftp/general
    chmod 555 /srv/ftp/general
    chmod 444 /srv/ftp/general/bienvenida.txt

    echo ">>> Acceso anónimo configurado en /srv/ftp/general"
}

