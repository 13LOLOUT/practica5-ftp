#!/bin/bash
# ftp_functions.sh — Funciones para instalación y configuración de vsftpd

instalar_ftp() {
    echo ">>> Instalando vsftpd..."
    apt-get update -qq
    apt-get install -y vsftpd
    echo ">>> vsftpd instalado correctamente."
}

configurar_ftp() {
    echo ">>> Configurando /etc/vsftpd.conf..."
    cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    cat > /etc/vsftpd.conf << 'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=YES
anon_root=/srv/ftp/general
no_anon_password=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=$USER
local_root=/srv/ftp/usuarios/$USER
pam_service_name=vsftpd
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOF

    echo ">>> vsftpd.conf configurado."
}

habilitar_ftp() {
    echo ">>> Habilitando y reiniciando vsftpd..."
    systemctl enable vsftpd
    systemctl restart vsftpd
    echo ">>> vsftpd activo."
}

estado_ftp() {
    echo ">>> Estado del servicio vsftpd:"
    systemctl status vsftpd
}

configurar_firewall_ftp() {
    echo ">>> Configurando UFW para FTP (puertos 20 y 21)..."
    ufw allow 20/tcp
    ufw allow 21/tcp
    echo ">>> Reglas de firewall FTP aplicadas."
}
