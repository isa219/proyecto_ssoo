#!/bin/bash

if [ "$#" == "0" ]; then

        echo "testing: falta un parametro"
        echo "Pruebe 'testing --help' para más informacíon"

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

                echo "testing [ install { ansible | docker | comandos } ] [ unistall ] [ start ] [ stop ] [ edit { ambito direccion_red mascara IP_inicio IP_final IP_gateway IP_DNS | reserva IP MAC } ] [ --help ]"

        elif [ "$1" == "info" ]; then

                ip=$(ip -c a | tail -6 | grep -E "[0-9]{3}\." | cut -d" " -f6)
                estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7)
                echo "Dirección IP de la maquina: $ip"
                echo "Estado del servicio: $estado"
	else
		echo "testing: mal primer argumento"
        	echo "Pruebe 'testing --help' para más informacíon"
        fi
elif [ "$#" == "2" ]; then
	if [ "$1" == "install" ];then
		if [ "$2" == "comandos" ]; then
			apt install isc-dhcp-server -y
		else
			echo "testing: mal segundo argumento"
        		echo "Pruebe 'testing --help' para más informacíon"
		fi
	else
		echo "testing: mal segundo argumento"
                echo "Pruebe 'testing --help' para más informacíon"
	fi
elif [ "$#" == "3" ]; then
	if [ "$1" == "edit" ]; then
                if [ "$2" == "reserva" ]; then
			comprobar_ip=$(echo $2 | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"")
                	if [ "$comprobar_ip" == "" ]; then
                        	echo "Íntroduce una dirección IP correcta"
			else

                        	sed -i "84s/.*/  fixed-address $3/" /etc/dhcp/dhcpd.conf
                        	echo "Dirección IP de reserva modificada con exito"
			fi
                fi
	else
		echo "testing: mal segundo argumento"
                echo "Pruebe 'testing --help' para más informacíon"
	fi
elif [ "$#" == "4" ]; then
        echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"
elif [ "$#" == "5" ]; then
        echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"
elif [ "$#" == "6" ]; then
        echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"
elif [ "$#" == "7" ]; then
        echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"
elif [ "$#" == "8" ]; then
        if [ "$1" == "edit" ]; then
		comprobar_red=$(echo $2 | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}")
		if [ "$comprobar_red" == "" ]; then
			echo "bien"
		else
			echo "mal"
		fi
	else

	echo "testing: mal primer argumento"
        echo "Pruebe 'testing --help' para más informacíon"
	fi
else
	echo "testing: mal argumentos"
        echo "Pruebe 'testing --help' para más informacíon"
fi
