#!/bin/bash 
                ip=$(ip -c a | tail -9 | grep -E "[0-9]{3}\." | cut -d" " -f6) 
                estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7) 
                echo "Dirección IP de la maquina: $ip" 
                echo "Estado del servicio: $estado" 
instalar_servicio() { 
    while true; do 
        echo -e "\nMenú de Instalación:" 
        echo "1. Con comandos directos" 
        echo "2. Con Ansible" 
        echo "3. Con Docker" 
        echo "0. Volver al menú principal" 
        read -p "Selecciona una opción: " opcion_sub 
        case $opcion_sub in 
            1) 
                echo "Instalando con comandos directos..." 
                sudo apt-get update 
                sudo apt-get install -y isc-dhcp-server 
                echo "Servicio DHCP instalado con comandos directos" 
                ;; 
            2) 
    		echo "Instalando con Ansible..." 
    		sudo apt update 
    		sudo apt install ansible 
    		read -p "Ingresa la dirección IP del host remoto: " remote_ip 
    		if ! [[ $remote_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then 
       			echo "Error: Formato de dirección IP inválido. Saliendo..." 
    		else 
        		read -p "Ingresa el nombre de usuario SSH del host remoto: " remote_user 
        	if [[ -z $remote_user ]]; then 
           		 echo "Error: El nombre de usuario SSH no puede estar vacío. Saliendo..." 
        	else 
            		read -s -p "Ingresa la contraseña SSH del host remoto: " remote_pass 
            	if [[ -z $remote_pass ]]; then 
               	 	echo "Error: La contraseña SSH no puede estar vacía. Saliendo..." 
           	else 
			echo "hola" 
			echo "[DHCP]" >> ./host.txt 
                	echo "$remote_ip ansible_ssh_user=$remote_user ansible_ssh_pass=$remote_pass" >> ./host.txt 
			echo "$remote_ip ansible_python_interpreter=/usr/bin/python3" >> ./host.txt 
                cat << EOF > install_dhcp.yml 
--- 
- name: Instalar y configurar DHCP 
  hosts: DHCP 
  become: yes 
  tasks: 
    - name: Actualizar la caché de apt 
      apt: 
        update_cache: yes 
    - name: Instalar el servidor DHCP 
      apt: 
        name: isc-dhcp-server 
        state: present 
    - name: Crear el archivo /etc/network/interfaces si no existe 
      file: 
        path: /etc/network/interfaces 
        state: touch 
      become: yes 
    - name: Configurar la interfaz de red para DHCP 
      lineinfile: 
        path: "/etc/network/interfaces" 
        regexp: '^iface enp0s3' 
        line: 'iface enp0s3 inet dhcp' 
      become: yes 
    - name: Configurar el directorio para scripts 
      file: 
        path: "/home/$remote_user/scripts" 
        state: directory 
        mode: '0755' 
      become: yes 
    - name: Copiar el script al directorio de scripts 
      copy: 
        src: menu.sh 
        dest: "/home/$remote_user/scripts/menu.sh" 
        mode: '0755' 
      become: yes 
    - name: Configurar la interfaz para isc-dhcp-server 
      lineinfile: 
        path: /etc/default/isc-dhcp-server 
        regexp: '^INTERFACESv4=' 
        line: 'INTERFACESv4="enp0s3"' 
      become: yes 
  handlers: 
    - name: Reiniciar DHCP 
      service: 
        name: isc-dhcp-server 
        state: restarted 
EOF 
                echo "$remote_ip ansible_ssh_user=$remote_user ansible_ssh_pass=$remote_pass" > ./host 
                ansible-playbook -v install_dhcp.yml --extra-vars "ansible_sudo_pass=$remote_pass" 
            fi 
        fi 
    fi 

                ;; 
            3) 
                echo "Instalando con Docker..." 
		sudo apt update 
		sudo apt install apt-transport-https ca-certificates curl software-properties-common 
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" 
		sudo apt update 
		apt-cache policy docker-ce 
		sudo apt install -y docker-ce 
		sudo docker build -t dhcp_server 
		sudo docker run -itd -p 66:66/udp dhcp_server 
		echo "servicio instalado a traves de docker" 
                ;; 
            0) 
                echo "Volviendo al menú principal." 
                break 
                ;; 
            *) 
                echo "Opción no válida. Inténtalo de nuevo." 
                ;; 
        esac 
    done 
} 
eliminar_servicio() { 
    sudo apt-get purge -y isc-dhcp-server 
    sudo apt-get autoremove -y 
    echo "Servicio DHCP eliminado." 
} 
iniciar_servicio() { 
    sudo service isc-dhcp-server start 
    echo "Servicio DHCP iniciado." 
} 
detener_servicio() { 
    sudo service isc-dhcp-server stop 
    echo "Servicio DHCP detenido." 
} 
configurar_servicio(){ 
    read -p "Ingresa la direccion de red: " ip 
    read -p "Ingresa la mascara de subred" mascara 
    read -p "Ingresa el rango de direcciones (ejemplo: 192.168.1.10 192.168.1.100): " address_range 
    read -p "Ingresa el servidor DNS (ejemplo: 8.8.8.8): " dns_server 
    read -p "Ingresa la puerta de enlace (ejemplo: 192.168.1.1): " gateway 
    read -p "Ingresa una IP para reservarla: " res 
    read -p "Ingresa la direccion mac" mac 
    read -p "dime el nombre de tu reserva" nombre 
    read -p "Ingresa puerto de escucha: " puerto 
    if [ -z "$ip" ] || [ -z "$address_range" ] || [ -z "$dns_server" ] || [ -z "$gateway" ]; then 
        echo "Error: Al menos una de las variables está vacía. Saliendo..." 
    fi 
    sed -i "53s/.*/subnet $ip netmask $mascara {/" /etc/dhcp/dhcpd.conf 
    sed -i "54s/.*/  range $address_range;/" /etc/dhcp/dhcpd.conf 
    sed -i "55s/.*/  option domain-name-servers $dns_server;/" /etc/dhcp/dhcpd.conf 
    sed -i "58s/.*/  option routers $gateway;/" /etc/dhcp/dhcpd.conf 
    sed -i "62s/.*/}/" /etc/dhcp/dhcpd.conf 
    sed -i "17s/.*/INTERFACESv4='$puerto'/" /etc/default/isc-dhcp-server 
    sed -i "82s/.*/host $nombre {/" /etc/dhcp/dhcpd.conf 
    sed -i "83s/.*/  hardware ethernet $mac;/" /etc/dhcp/dhcpd.conf 
    sed -i "84s/.*/  fixed-address $res;/" /etc/dhcp/dhcpd.conf 
    sed -i "85s/.*/}/" /etc/dhcp/dhcpd.conf 
   echo "Configuracion completada" 
} 

main() { 
    while true; do 
        echo -e "\nMenú de Acciones:" 
        echo "1. Instalar Servicio DHCP" 
        echo "2. Eliminar Servicio DHCP" 
        echo "3. Iniciar Servicio DHCP" 
        echo "4. Detener Servicio DHCP" 
        echo "5. Configurar Servicio DHCP" 
        echo "0. Salir" 
        read -p "Selecciona una opción: " opcion 
        case $opcion in 
            1) instalar_servicio;; 
            2) eliminar_servicio;; 
            3) iniciar_servicio;; 
            4) detener_servicio;; 
            5) configurar_servicio;; 
            0) echo "Saliendo del script. ¡Hasta luego!"; exit;; 
            *) echo "Opción no válida. Inténtalo de nuevo.";; 
        esac 
    done 
} 
main 