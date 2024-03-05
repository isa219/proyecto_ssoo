#!/bin/bash
if [ "$#" == "0" ]; then

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
    read -p "Ingresa la mascara de subred: " mascara 
    read -p "Ingresa el rango de direcciones (ejemplo: 192.168.1.10 192.168.1.100): " address_range 
    read -p "Ingresa el servidor DNS (ejemplo: 8.8.8.8): " dns_server 
    read -p "Ingresa la puerta de enlace (ejemplo: 192.168.1.1): " gateway 
    read -p "Ingresa una IP para reservarla: " res 
    read -p "Ingresa la direccion mac: " mac 
    read -p "dime el nombre de tu reserva: " nombre 
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
        ip=$(ip -c a | tail -25 | grep -E "[0-9]{3}\." | cut -d" " -f6)
        estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7)
     	echo "Direcciones IP de la maquina:"
        echo "$ip"
        echo "Estado del servicio: $estado"
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

elif [ "$#" == "1" ]; then

        if [ "$1" == "unistall" ]; then

		apt purge isc-dhcp-server -y
                echo "Desinstalación con exito"

        elif [ "$1" == "start" ]; then

                service isc-dhcp-server start
                echo "Servicio inicializado correctamente"

        elif [ "$1" == "stop" ]; then

                service isc-dhcp-server stop
                echo "Servicio parado correctamente"

        elif [ "$1" == "--help" ]; then

                echo "testing [ install { ansible { IP_remota usuario_remoto pass_remota } | docker | comandos } ] [ unistall ] [ start ] [ stop ] [ edit { ambito direccion_red mascara IP_inicio IP_final IP_gateway IP_DNS | reserva nombre IP MAC | puerto_escucha puerto } ] [ --help ] [ info ]"

        elif [ "$1" == "info" ]; then

                ip=$(ip -c a | tail -25 | grep -E "[0-9]{3}\." | cut -d" " -f6)
                estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7)

                echo "Direcciones IP de la maquina:"
		echo "$ip"
                echo "Estado del servicio: $estado"

	elif [ "$1" == "install" ]; then

		echo "testing: falta otro argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	elif [ "$1" == "edit" ]; then

		echo "testing: mal faltan argumentos"
                echo "Pruebe 'testing --help' para más informacíon"
	else

		echo "testing: mal primer argumento"
        	echo "Pruebe 'testing --help' para más informacíon"

        fi

elif [ "$#" == "2" ]; then

	if [ "$1" == "install" ];then

		if [ "$2" == "comandos" ]; then

			apt update -y
			apt install isc-dhcp-server -y
			echo "Instalacion completada"

		elif [ "$2" == "docker" ]; then

			sudo docker build -t dhcp_server .
			sudo docker run -itd -p 66:66/udp dhcp_server

		elif [ "$2" == "ansible" ]; then

			echo "testing: mal faltan argumentos"
                        echo "Pruebe 'testing --help' para más informacíon"

		else

			echo "testing: mal segundo argumento"
        		echo "Pruebe 'testing --help' para más informacíon"

		fi

	elif [ "$1" == "edit" ]; then

		if [ "$2" == "reserva" ]; then

			echo "testing: mal faltan argumentos"
                	echo "Pruebe 'testing --help' para más informacíon"

		elif [ "$2" == "ambito" ]; then

			echo "testing: mal faltan argumentos"
                        echo "Pruebe 'testing --help' para más informacíon"

		elif [ "$2" == "puerto_escucha" ]; then

			echo "testing: mal faltan argumentos"
                        echo "Pruebe 'testing --help' para más informacíon"

		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "3" ]; then

	if [ "$1" == "edit" ]; then

		if [ "$2" == "reserva" ]; then

			echo "testing: mal faltan argumentos"
                        echo "Pruebe 'testing --help' para más informacíon"

		elif [ "$2" == "ambito" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
			if [ "$comprobar_ip" != "" ]; then

				echo "testing: mal faltan argumentos"
                        	echo "Pruebe 'testing --help' para más informacíon"

			else

				echo "Íntroduce una dirección de red correcta"

			fi

		elif [ "$2" == "puerto_escucha" ]; then

                        sed -i "17s/.*/INTERFACESv4='$3'/" /etc/default/isc-dhcp-server
			echo "Puerto de escucha configurado con exito"

		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	elif [ "$1" == "install" ]; then

		if [ "$2" == "ansible" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				echo "testing: mal faltan argumentos"
                                echo "Pruebe 'testing --help' para más informacíon"

			else

				echo "Íntroduce una dirección de IP correcta"

			fi

		else

			echo "testing: mal segundo argumento"
                        echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "4" ]; then

	if [ "$1" == "edit" ]; then

                if [ "$2" == "reserva" ]; then

			comprobar_ip=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                	if [ "$comprobar_ip" == "" ]; then

                        	echo "Íntroduce una dirección IP correcta"

			else

                        	echo "testing: mal faltan argumentos"
                                echo "Pruebe 'testing --help' para más informacíon"

			fi
                elif [ "$2" == "ambito" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				comprobar_mascara=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
				if  [ "$comprobar_mascara" != "" ]; then

					echo "testing: mal faltan argumentos"
                        		echo "Pruebe 'testing --help' para más informacíon"

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección de red correcta"

			fi
		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	elif [ "$1" == "install" ]; then

		if [ "$2" == "ansible" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				echo "testing: mal faltan argumentos"
                                echo "Pruebe 'testing --help' para más informacíon"

			else

				echo "Íntroduce una dirección IP correcta"

			fi

		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "5" ]; then

        if [ "$1" == "edit" ]; then

		if [ "$2" == "ambito" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				comprobar_mascara=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                if  [ "$comprobar_mascara" != "" ]; then

					comprobar_ip=$(echo $5 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        		if [ "$comprobar_ip" != "" ]; then

						echo "testing: mal faltan argumentos"
                                		echo "Pruebe 'testing --help' para más informacíon"

					else

						echo "Íntroduce una dirección IP de inicio correcta"

					fi

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección de red correcta"

			fi

		elif [ "$2" == "reserva" ]; then

			comprobar_ip=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				comprobar_mac=$(echo $5 | grep -E "^[0-9a-zA-Z]{2}\:([0-9a-zA-Z]{2}\:){4}[0-9a-zA-Z]{2}$")
                                if  [ "$comprobar_mac" != "" ]; then

					sed -i "82s/.*/host $3 {/" /etc/dhcp/dhcpd.conf
					sed -i "83s/.*/  hardware ethernet $5;/" /etc/dhcp/dhcpd.conf
					sed -i "84s/.*/  fixed-address $4;/" /etc/dhcp/dhcpd.conf
					sed -i "85s/.*/}/" /etc/dhcp/dhcpd.conf

                                        echo "Dirección IP de reserva modificada con exito"

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección IP correcta"

			fi

		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	elif [ "$1" == "install" ]; then

		if [ "$2" == "ansible" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" != "" ]; then

				sed -i "2s#.*#$3 ansible_ssh_user=$4 ansible_ssh_pass=$5#" ./host.txt
				sed -i "3s#.*#$3 ansible_python_interpreter=/usr/bin/python3#" ./host.txt

				sed -i "31s#.*#\        path: \"/home/$4/scripts\"#" ./install_dhcp.yml
				sed -i "39s#.*#\        dest: \"/home/$4/scripts/script_dhcpd.sh\"#" ./install_dhcp.yml
				sed -i "38s#.*#\        src: script_dhcpd.sh#" ./install_dhcp.yml
				ansible-playbook -v install_dhcp.yml --extra-vars ansible_sudo_pass=$5
				echo "Instalacion con Ansible completada"

				#sed -i "3s#.*#\"$3\" ansible_python_interpreter=/usr/bin/python3#" ./
				#sed -i "3s#.*#\"$3\" ansible_python_interpreter=/usr/bin/python3#" ./host.txt
			else

				echo "Íntroduce una dirección IP correcta"

			fi

		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "6" ]; then

        if [ "$1" == "edit" ]; then

		if [ "$2" == "ambito" ]; then

			comprobar_red=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_red" != "" ]; then

				comprobar_mascara=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                if  [ "$comprobar_mascara" != "" ]; then

					comprobar_ip_inicio=$(echo $5 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                        if [ "$comprobar_ip_inicio" != "" ]; then

						comprobar_ip_final=$(echo $6 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                        	if [ "$comprobar_ip_final" != "" ]; then

							echo "testing: mal faltan argumentos"
                                                	echo "Pruebe 'testing --help' para más informacíon"

						else

							echo "Íntroduce una dirección IP de final correcta"

						fi

					else

						echo "Íntroduce una dirección IP de inicio correcta"

					fi

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección de red correcta"

			fi

		else

			echo "testing: mal primer argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "7" ]; then

        if [ "$1" == "edit" ]; then

		if [ "$2" == "ambito" ]; then

			comprobar_red=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_red" != "" ]; then

				comprobar_mascara=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                if  [ "$comprobar_mascara" != "" ]; then

					comprobar_ip_inicio=$(echo $5 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                        if [ "$comprobar_ip_inicio" != "" ]; then

						comprobar_ip_final=$(echo $6 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                                if [ "$comprobar_ip_final" != "" ]; then

							comprobar_ip_gateway=$(echo $7 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                                	if [ "$comprobar_ip_gateway" != "" ]; then

								echo "testing: mal faltan argumentos"
                                                        	echo "Pruebe 'testing --help' para más informacíon"

							else

								echo "Íntroduce una dirección IP de gateway correcta"

							fi

						else

							echo "Íntroduce una dirección IP de final correcta"

						fi

					else

						echo "Íntroduce una dirección IP de inicio correcta"

					fi

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección de red correcta"

			fi
		else

			echo "testing: mal segundo argumento"
                	echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

elif [ "$#" == "8" ]; then

        if [ "$1" == "edit" ]; then

		if [ "$2" == "ambito" ]; then

			comprobar_red=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_red" != "" ]; then

				comprobar_mascara=$(echo $4 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                if  [ "$comprobar_mascara" != "" ]; then

					comprobar_ip_inicio=$(echo $5 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                        if [ "$comprobar_ip_inicio" != "" ]; then

						comprobar_ip_final=$(echo $6 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                                if [ "$comprobar_ip_final" != "" ]; then

							comprobar_ip_gateway=$(echo $7 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                                        if [ "$comprobar_ip_gateway" != "" ]; then

								comprobar_ip_dns=$(echo $8 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                                                        	if [ "$comprobar_ip_dns" != "" ]; then

									sed -i "53s/.*/subnet $3 netmask $4 {/" /etc/dhcp/dhcpd.conf
									sed -i "54s/.*/  range $5 $6;/" /etc/dhcp/dhcpd.conf
									sed -i "55s/.*/  option domain-name-servers $8;/" /etc/dhcp/dhcpd.conf
									sed -i "58s/.*/  option routers $7;/" /etc/dhcp/dhcpd.conf
									sed -i "62s/.*/}/" /etc/dhcp/dhcpd.conf

									echo "Ambito configurado con exito"
								else

									echo "Íntroduce una dirección IP de servidor DNS correcta"

								fi

							else

								echo "Íntroduce una dirección IP de gateway correcta"

							fi

						else

							echo "Íntroduce una dirección IP de final correcta"

						fi

					else

						echo "Íntroduce una dirección IP de inicio correcta"

					fi

				else

					echo "Íntroduce una mascara correcta"

				fi

			else

				echo "Íntroduce una dirección de red correcta"

			fi

		else

			echo "testing: mal segundo argumento"
                        echo "Pruebe 'testing --help' para más informacíon"

		fi

	else

		echo "testing: mal primer argumento"
                echo "Pruebe 'testing --help' para más informacíon"

	fi

else

	echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"

fi
