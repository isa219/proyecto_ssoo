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

                echo "testing [ install { ansible | docker | comandos } ] [ unistall ] [ start ] [ stop ] [ edit { ambito IP mascara IP_inicio IP_final IP_gateway IP_DNS | reserva IP } ] [ --help ] [ inf>"

        elif [ "$1" == "info" ]; then

                ip=$(ip -c a | tail -6 | grep -E "[0-9]{3}\." | cut -d" " -f6)
                estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7)
                echo "Dirección IP de la maquina: $ip"
                echo "Estado del servicio: $estado"
        fi
elif [ "$#" == "2" ]; then
        echo "2 parametros"
        if [ "$1" == "install" ] $$ [ "$2" == "comandos"]; then

                echo "Se esta instalando, bien"
        else
                echo "mal"
        fi
fi
