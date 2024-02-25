
#!/bin/bash


instalar_con_comandos() {
    sudo apt-get update
    sudo apt-get install -y isc-dhcp-server
    echo "Servicio DHCP instalado con comandos"
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

main() {
    while true; do
        echo -e "\nMenú de Acciones:"
        echo "1. Instalar Servicio DHCP con Comandos"
        echo "2. Eliminar Servicio DHCP"
        echo "3. Iniciar Servicio DHCP"
        echo "4. Detener Servicio DHCP"
        echo "0. Salir"

        read -p "Selecciona una opción: " opcion

        case $opcion in
            1) instalar_con_comandos;;
            2) eliminar_servicio;;
            3) iniciar_servicio;;
	    4) detener_servicio;;
            0) echo "Saliendo del script. ¡Hasta luego!"; exit;;
            *) echo "Opción no válida. Inténtalo de nuevo.";;
        esac
    done
}

main
