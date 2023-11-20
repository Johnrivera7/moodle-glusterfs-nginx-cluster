#!/bin/bash

function update-ubuntu {
    echo -e "\e[0m"
    echo -e "\e[1;37m [+] Iniciando actualización del sistema operativo e instalación de dependencias.\e[0m"

    # Actualizar lista de paquetes
    echo -ne "\e[1;37m  >> Actualizando lista de paquetes [\e[0m"
    sudo apt-get update | tee -a debug.txt
    echo -e "\e[1;32mOK\e[1;37m]\e[0m"

    # Actualizar paquetes
    echo -ne "\e[1;37m  >> Actualizando paquetes instalados [\e[0m"
    sudo apt-get upgrade  -y | tee -a debug.txt
    echo -e "\e[1;32mOK\e[1;37m]\e[0m"

    echo -e "\e[1;37m [+] Actualización completa\e[0m"
}



# install PHP web server with modules for PostgreSQL
function php-web-server {
    echo -e "\e[1;34m \n  Instalación de servidor web PHP con módulos para PostgreSQL.
 #################################################################\e[0m\n"

    # Instalación de Nginx
    sudo apt install nginx -y | tee -a debug.txt | echo -e "\e[1;37m [+] Instalando Nginx . . . . .\e[0m"
    echo -e "  >> Nginx instalado  [\e[1;32mOK\e[1;37m]\e[0m"

    # Instalación de PHP y módulos adicionales para PostgreSQL
    sudo apt install php-fpm php-mbstring php-curl php-xmlrpc php-soap php-zip php-gd php-xml php-intl php-json php-pgsql php-redis -y | tee -a debug.txt | echo -e "\e[1;37m [+] Instalación de PHP y módulos adicionales . . . . .\e[0m"
    echo -e "  >> PHP instalado  [\e[1;32mOK\e[1;37m]\e[0m"

    # Reiniciar Nginx
    sudo systemctl restart nginx | tee -a debug.txt | echo -e "\e[1;37m [+] Reiniciando Nginx . . . . .\e[0m"
    echo -e "  >> Nginx reiniciado  [\e[1;32mOK\e[1;37m]\e[0m"
}

function php-web-server-output {
    echo -e "\e[1;37m [+] Detalles del servidor web PHP \e[0m"
    lsb_release -a | grep Description
    sudo dpkg -l nginx | grep ii
    php -v | grep PHP
}

function moodle-app {
  # Preguntar al usuario por el dominio
  read -p "Ingrese el dominio del sitio Moodle: " DOMAIN

  echo -e "\e[1;34m \nObteniendo Moodle desde GIT.\n#################################################################\e[0m\n"

    # Asegurarse de que el directorio /var/www/$DOMAIN no exista
  if [ ! -d "/var/www/$DOMAIN" ]; then
    # La carpeta no existe, crearla
    sudo mkdir -p "/var/www/$DOMAIN"
    echo -e "\e[1;37m [+] Creando directorio en /var/www/$DOMAIN . . . . .\e[0m"
  else
    # La carpeta ya existe, mostrar mensaje y salir
    echo -e "\e[1;37m [+] El directorio /var/www/$DOMAIN ya existe. No se realizaron cambios, comprimiendo el directorio y renombrando con fecha y hora actual. . . . .\e[0m"
  fi


  # Asegurarse de que el directorio /var/www/$DOMAIN/moodle no exista
  MOODLE_PATH="/var/www/$DOMAIN/moodle"
  if [ -d "$MOODLE_PATH" ]; then
    # La carpeta moodle ya existe, comprimir y renombrar
    TIMESTAMP=$(date "+%Y%m%d%H%M%S")
    sudo tar czf "/var/www/$DOMAIN/moodle_$TIMESTAMP.tar.gz" -C /var/www/$DOMAIN/ moodle
    sudo rm -rf "$MOODLE_PATH"
    echo -e "\e[1;37m [+] Carpeta moodle existente comprimida y renombrada con fecha y hora actual. . . . .\e[0m"
  fi

  git clone -b MOODLE_403_STABLE https://github.com/moodle/moodle.git /var/www/$DOMAIN/moodle/ | tee -a debug.txt
  echo -e "\e[1;37m [+] Descargando Moodle v4.3 desde GitHub. . . . .\e[0m"
  echo -e "  >> Descarga completa de Moodle  [\e[1;32mOK\e[1;37m]\e[0m"

  # Obtener la versión de PHP instalada en el sistema
  PHP_PATH=$(which php)
  PHP_VERSION=$($PHP_PATH -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')


  echo -e "\e[1;37m [+] Cambiando permisos de la carpeta moodle . . . . .\e[0m"
  sudo chown -R www-data:www-data /var/www/$DOMAIN/moodle/
  sudo chmod -R 0755 /var/www/$DOMAIN/moodle/
  sudo find /var/www/$DOMAIN/moodle -type f -exec chmod 0644 {} \;
  echo -e "  >> Cambio de permisos [\e[1;32mOK\e[1;37m]\e[0m"

  sudo rm -Rf /var/www/$DOMAIN/html/
  echo -e "\e[1;37m [+] Actualizando carpeta del sitio predeterminado a moodle . . . . .\e[0m"

  # Cambiando la carpeta de moodle como carpeta web predeterminada
  sudo sed -i 's/html/moodle/g' /etc/nginx/sites-available/default
  sudo service nginx reload
  echo -e "  >> Actualizado la carpeta del sitio predeterminado a moodle  [\e[1;32mOK\e[1;37m]\e[0m"

  # Crear la carpeta moodledata y cambiar permisos
  echo -e "\e[1;37m [+] Creando y cambiando permisos de la carpeta moodledata . . . . .\e[0m"
  
  if [ ! -d "/var/www/$DOMAIN/moodledata" ]; then
    # La carpeta no existe, crearla
    sudo mkdir -p "/var/www/$DOMAIN/moodledata"
    echo -e "\e[1;37m [+] Creando directorio en /var/www/$DOMAIN/modledata . . . . .\e[0m"
  else
    # La carpeta ya existe, mostrar mensaje y salir
    TIMESTAMP=$(date "+%Y%m%d%H%M%S")
    sudo tar czf "/var/www/$DOMAIN/moodledata_$TIMESTAMP.tar.gz" -C /var/www/$DOMAIN/ moodledata
    sudo rm -rf /var/www/$DOMAIN/moodledata
    sudo mkdir -p /var/www/$DOMAIN/moodledata
    echo -e "\e[1;37m [+] Carpeta moodledata existente comprimida y renombrada con fecha y hora actual. . . . .\e[0m"
    echo -e "\e[1;37m [+] El directorio /var/www/$DOMAIN/modledata ya existe. No se comprimio cambios.\e[0m"
  fi
  sudo chmod 0777 /var/www/$DOMAIN/moodledata/
  sudo chown -R www-data:www-data /var/www/$DOMAIN/moodledata/
  echo -e "  >> Carpeta creada y permisos cambiados [\e[1;32mOK\e[1;37m]\e[0m"
1
  # Configuración de Nginx para Moodle
  NGINX_CONFIG="/etc/nginx/sites-available/$DOMAIN"
  sudo tee $NGINX_CONFIG > /dev/null <<EOF
server {
    listen 80;
    root /var/www/$DOMAIN/moodle/;
    index index.php index.html index.htm;
    server_name $DOMAIN;
    access_log /var/log/nginx/$DOMAIN-access.log;
    error_log /var/log/nginx/$DOMAIN-error.log;

    client_max_body_size 100M;
    client_body_buffer_size 128k;
    autoindex off;

    location / {
        try_files \$uri \$uri/ =404;
    }

    fastcgi_read_timeout 1200s;

    location ~ [^/].php(/|$) {
        include snippets/fastcgi-php.conf;
        fastcgi_send_timeout 900;
        fastcgi_read_timeout 900;
        fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
    }

    # La siguiente sección es para la gestión de archivos dataroot de Moodle
    location /dataroot/ {
        internal;
        alias /var/www/$DOMAIN/moodledata/;
    }
}
EOF

  # Crear enlace simbólico a la configuración
  sudo ln -s $NGINX_CONFIG /etc/nginx/sites-enabled/
  sudo service nginx reload

  echo -e "\e[1;37m [+] Configuración de Nginx creada y recargada . . . . .\e[0m"
  echo -e "  >> Puede acceder a su sitio Moodle en http://$DOMAIN/"
}

function output-moodle {
                    echo -e "\e[1;34m \n  Moodle hosting Link.
 #################################################################\e[0m\n" 

www=$(dig +short myip.opendns.com @resolver1.opendns.com) 
echo -e "\e[1;37m [+]  Visit  http://$www si ha habilitado SSL Visita https://$www  
                                        [\e[1;32m Completo \e[1;37m]\e[0m"

} 

function input-ip {
    read -p "Ingrese el número de nodos Moodle: " num_nodes

    for ((i=1; i<=$num_nodes; i++)); do
        read -p "Ingrese la dirección IP del servidor Moodle $i: " ip
        nodes_ips+=("$ip")
    done
}

function ping-nodes {
    echo -e "\e[1;34m \n  Haciendo ping a los nodos Moodle para asegurarse de que estén en funcionamiento.
 #################################################################\e[0m" 

    for ((i=0; i<$num_nodes; i++)); do
        ping -c 1 "${nodes_ips[$i]}" 1> /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "  >> Moodle Nodo $((i+1)) - \e[1;37m ${nodes_ips[$i]} es accesible\e[0m"
        else
            echo -e "\e[1;31m  >> Moodle Nodo $((i+1)) - ${nodes_ips[$i]} inaccesible\e[0m"
            read -p "  ¿Desea cambiar la dirección IP del nodo $((i+1))? (s/n): " change_ip
            if [ "$change_ip" == "s" ]; then
                read -p "  Ingrese la nueva dirección IP para el nodo $((i+1)): " new_ip
                nodes_ips[$i]=$new_ip
                echo -e "\e[1;37m  [+] Dirección IP actualizada a $new_ip\e[0m"
                
                # Hacer ping nuevamente después de actualizar la dirección IP
                ping -c 1 "$new_ip" 1> /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "  >> Moodle Nodo $((i+1)) - \e[1;37m $new_ip es accesible\e[0m"
                else
                    echo -e "\e[1;31m  >> Moodle Nodo $((i+1)) - $new_ip sigue siendo inaccesible. El script se detendrá.\e[0m"
                    exit 1
                fi
            else
                echo -e "\e[1;31m  >> No se realizaron cambios en la dirección IP. El script se detendrá.\e[0m"
                exit 1
            fi
        fi
    done
}


function select-glusterfs-server {
    echo -e "\e[1;34m \n  Seleccione su HOST actual para usarlo en el clúster Moodle 
 #################################################################\e[0m" 

    for ((i=0; i<$num_nodes; i++)); do
        echo -e "\e[1;37m $((i+1)). Moodle-000$((i+1)) - ${nodes_ips[$i]}\e[0m"
    done

    echo -e "\e[1;32m"
    read -p "Ingrese su elección:" option
    echo -e "\e[0m"

    if ((option >= 1 && option <= $num_nodes)); then
        echo -e "\e[1;37m  [+] Usted ha seleccionado \e[1;32m Moodle-000$option\e[0m"
        sudo hostnamectl set-hostname "moodle-000$option"
        host=$(hostname)
        
        # Actualizar /etc/hosts con las direcciones IP de los nodos
        echo -e "\e[1;37m  [+] Escribiendo direcciones IP en /etc/hosts\e[0m"
        echo "127.0.0.1 $host" > /etc/hosts

        for ((i=0; i<$num_nodes; i++)); do
            if [ $((i+1)) -ne $option ]; then
                echo "${nodes_ips[$i]}  moodle-000$((i+1))" >> /etc/hosts
            fi
        done
    else
        echo -e "\e[1;31m  >> Su entrada no es válida - \e[1;32m $option \n\e[0m"
        exit 1
    fi

    echo -e "\e[1;37m  [+] Direcciones IP escritas en /etc/hosts"
    host=$(hostname)
    echo -e "\e[1;37m  [+] Nombre de host escrito en /etc/hostname - usted está en \e[1;32m $host \e[0m "
    echo -e "\e[0m"
}


function install-glusterfs {

        echo -e "\e[1;34m \n  Instalación de GlusterFS y dependencias
#######################################\e[0m"
        echo -e "Instalando las dependencias.  \n\e[0m"

        sudo apt install glusterfs-server -y | tee -a debug.txt | echo -e "\e[1;37m [+] Instalando GlusterFS . . . . .\e[0m"
        echo -e "  >> GlusterFS instalado [\e[1;32mOK\e[1;37m]\e[0m"

        sudo systemctl start glusterd | tee -a debug.txt | echo -e "\e[1;37m [+] Iniciando GlusterFS . . . . .\e[0m"
        echo -e "  >> GlusterFS iniciado [\e[1;32mOK\e[1;37m]\e[0m"

        sudo systemctl enable glusterd | tee -a debug.txt | echo -e "\e[1;37m [+] Habilitando GlusterFS . . . . .\e[0m"
        echo -e "  >> GlusterFS habilitado [\e[1;32mOK\e[1;37m]\e[0m"

        if [ ! -d "/glusterfs" ]; then
            # La carpeta no existe, crearla
            sudo mkdir -p "/glusterfs"
            echo -e "\e[1;37m [+] Creando directorio en /glusterfs . . . . .\e[0m"
        else
            # La carpeta ya existe, mostrar mensaje y salir
            echo -e "\e[1;37m [+] El directorio /glusterfs ya existe. No se realizaron cambios.\e[0m"
          fi
       
        echo -e "\e[1;37m [+] /carpeta glusterfs creada [\e[1;32mOK\e[1;37m]\e[0m"


}

function probe-glusterfs {
        echo -e "\e[1;34m \n  Probing Moodle Nodes
#######################################\e[0m"

        if [ "$host" == "moodle-0001" ] ;
        then
            echo -e "\e[1;37m\n  [+] Configurar moodle-0001 como nodo maestro\e[0m"
            echo -e "\e[1;37m  [+] Sondeando moodle-0002\e[0m" && gluster peer probe moodle-0002 
            echo -e "\e[1;37m  [+] Sondeando moodle-0003\e[0m" && gluster peer probe moodle-0003 
            echo -e "\e[1;37m  [+] Creando el volumen GlusterFS gv0\e[0m" && sudo gluster volume create gv0 replica 3 transport tcp moodle-0001:/glusterfs moodle-0002:/glusterfs moodle-0003:/glusterfs force
            # intenté esto pero no se ve mejoras de rapidez sudo gluster volume create gv1 replica 3 moodle-0001:/mnt/glusterfs_attach moodle-0002:/mnt/glusterfs_attach moodle-0003:/mnt/glusterfs_attach force
            echo -e "\e[1;37m  [+] Iniciando el volumen GlusterFS gv0\e[0m" && sudo gluster volume start gv0
            echo -e "\e[1;37m  [+] Información del volumen de GlusterFS\e[0m" && sudo gluster volume info
            # Agregar la línea de montaje a /etc/fstab para montar automáticamente al iniciar
            echo -e "\e[1;37m [+] Configurando montaje automático en /etc/fstab . . . . .\e[0m"
            echo "moodle-0001:/gv0 /var/www/ glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
            echo -e "  >> Configuración de montaje automático en /etc/fstab [\e[1;32mOK\e[1;37m]\e[0m"
            moodle-app
            output-moodle

         else
            echo -e "\e[1;37m  [-] Esto no es moodle-0001, el script se está ejecutando $host, omitiendo la configuración del nodo maestro \e[0m "
            echo -e "\e[1;37m [+] Configurando montaje automático en /etc/fstab . . . . .\e[0m"
            echo "moodle-0001:/gv0 /var/www/ glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
            echo -e "  >> Configuración de montaje automático en /etc/fstab [\e[1;32mOK\e[1;37m]\e[0m"
         fi
 
            sudo mount -t glusterfs moodle-0001:/gv0 /var/www/
            echo -e "  >> Montaje en glusterfs moodle-0001:/gv0 /var/www/ [\e[1;32mOK\e[1;37m]\e[0m"
}

function gfs-output {

echo -e "\e[1;32m\n  ***Instalación Completa****\e[0m\n"
}



echo -e "\e[1;32m"

echo "

__________________________________________________________________________________________________

#     #                                        #####
##   ##  ####   ####  #####  #      ######    #     # #      #    #  ####  ##### ###### #####
# # # # #    # #    # #    # #      #         #       #      #    # #        #   #      #    #
#  #  # #    # #    # #    # #      #####     #       #      #    #  ####    #   #####  #    #
#     # #    # #    # #    # #      #         #       #      #    #      #   #   #      #####
#     # #    # #    # #    # #      #         #     # #      #    # #    #   #   #      #   #
#     #  ####   ####  #####  ###### ######     #####  ######  ####   ####    #   ###### #    #
__________________________________________________________________________________________________
Script para Instalar cluster Moodle con GlusterFS en servidores Linux

Author:  John Rivera González - <johnriveragonzalez@gmail.com>
Version: 0.1.2
__________________________________________________________________________________________________
Notas: -

- Debe crear la cantidan de instancias como nodos requiere
- Este script fue probado en instancias de ECS con Ubuntu 22.04
- Este Script instalara la versión más reciente de Moodle
- Debe tener FW o grupos de seguridad con los siguientes puertos abiertos:
    GlusterFS: 24007,111,49152-49251,2049
    Nginx: 80.443
    SSH: 22
__________________________________________________________________________________________________"
echo -e "\e[1;31m"
echo "
__________________________________________________________________________________________________

 *Debe iniciar este script primero en los nodos esclavos y finalmente en el nodo maestro 
__________________________________________________________________________________________________"

echo -e "\e[1;34m \n  Por favor seleccione su elección para la instalación
 #################################################################\e[0m" 
read -p " ¿Desea Implementar un cluster para moodle con Nginx Server y GlusterFS? (s/n): " install_cluster
if [ "$install_cluster" == "s" ]; then
    echo -e "\e[1;37m  [+] Comenzando con la instalación de \e[1;32m GlusterFS + Nginx Server + Moodle \e[0m\n"
            input-ip
            ping-nodes
            update-ubuntu
            php-web-server
            php-web-server-output
            select-glusterfs-server
            install-glusterfs
            probe-glusterfs
            gfs-output
else
    echo -e "\e[1;31m  >> No se realizaron cambios en la dirección IP. El script se detendrá.\e[0m"
    exit 1
fi
