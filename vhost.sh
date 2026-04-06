#!/bin/bash

# Uso para crear: sudo ./vhost.sh inube 4200
# Uso para borrar: sudo ./vhost.sh inube --remove

DOMAIN=$1
ACTION=$2 # Puede ser el puerto o "--remove"

if [ -z "$DOMAIN" ] || [ -z "$ACTION" ]; then
    echo "Uso crear:  sudo $0 <dominio> <puerto>"
    echo "Uso borrar: sudo $0 <dominio> --remove"
    exit 1
fi

# --- LÓGICA PARA ELIMINAR ---
if [ "$ACTION" == "--remove" ] || [ "$ACTION" == "-r" ]; then
    echo "Eliminando configuración para: $DOMAIN..."
    
    # Quitar del archivo hosts
    sed -i "/$DOMAIN/d" /etc/hosts
    
    # Quitar de Nginx
    rm -f /etc/nginx/sites-available/$DOMAIN
    rm -f /etc/nginx/sites-enabled/$DOMAIN
    
    systemctl restart nginx
    echo "¡Dominio $DOMAIN eliminado correctamente!"
    exit 0
fi

# --- LÓGICA PARA CREAR (Proxy Inverso) ---
PORT=$ACTION
CONFIG_PATH="/etc/nginx/sites-available/$DOMAIN"

# 1. Agregar al archivo hosts si no existe
if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "127.0.0.1 $DOMAIN" >> /etc/hosts
fi

# 2. Crear configuración de Nginx
cat <<EOF > $CONFIG_PATH
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# 3. Habilitar y reiniciar
ln -sf $CONFIG_PATH /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

echo "¡Configurado! http://$DOMAIN ahora apunta al puerto $PORT"
