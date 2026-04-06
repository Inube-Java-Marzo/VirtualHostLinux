# Local Virtual Hosts Manager 🚀

Este script automatiza la creación de **Dominios Virtuales** en entornos Linux, permitiendo acceder a tus proyectos mediante URLs personalizadas (ej. `http://inube`) en lugar de `http://localhost:port`.

## 🛠 Requisitos Previos

1. **Nginx instalado:**

   sudo apt update && sudo apt install nginx -y

2. **Permisos:**

    chmod +x vhost.sh

3. **Crear un nuevo dominio:**

    sudo ./vhost.sh app.inube 4200

4. **Eleminar un dominio existente:**

    sudo ./vhost.sh inube --remove


📦 Configuraciones Específicas por Framework
Para que el proxy inverso no cause problemas de seguridad o de recarga automática, sigue estos pasos:

🅰️ Para Angular
Angular tiene una protección de seguridad llamada "Host Check". Si intentas acceder vía http://inube sin configurar esto, verás un error de "Invalid Host Header".

Abre angular.json

Busca la ruta: projects -> Inube-front -> architect -> serve -> options.

Agrega o modifica estas líneas:

 "options": {
            "host": "localhost",
            "allowedHosts": ["inube", "localhost"]
          }

Ejecutar permitiendo el host específico.

    ng serve --allowed-hosts=inube


🍃 Para Spring Boot
Si tu backend en Spring maneja sesiones, cookies o redirecciones, es importante que reconozca que está detrás de un proxy.

Añade lo siguiente a tu archivo application.properties o application.yml:

Properties
# Permitir que Spring reconozca las cabeceras X-Forwarded-* enviadas por Nginx
server.forward-headers-strategy=framework

🔍 ¿Cómo funciona por dentro?
Mapeo DNS: Agrega la línea 127.0.0.1 dominio a /etc/hosts, redirigiendo el tráfico del nombre a tu propia máquina.

Proxy Inverso: Crea un archivo en /etc/nginx/sites-available/ que escucha en el puerto 80 (HTTP estándar) y reenvía todo el tráfico al puerto de tu servicio (4200, 8080, etc.).

Soporte WebSockets: El script incluye configuración para Upgrade y Connection, asegurando que el HMR (Hot Module Replacement) de Angular funcione y la página se actualice sola al guardar cambios.

📂 Estructura de Archivos Generados
Configuración Nginx: /etc/nginx/sites-available/tu-dominio

Enlace Simbólico: /etc/nginx/sites-enabled/tu-dominio

Registro de Host: /etc/hosts


---

### Un último tip:
Si vas a trabajar con microservicios (varios de Spring y uno de Angular al mismo tiempo), puedes ejecutar el script varias veces:
* `sudo ./vhost.sh app.local 4200`
* `sudo ./vhost.sh api.local 8080`
* `sudo ./vhost.sh auth.local 8081`

¡Y listo! Ya tienes una arquitectura local profesional.
