#!/bin/bash
                ip=$(ip -c a | tail -6 | grep -E "[0-9]{3}\." | cut -d" " -f6)
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

                ;;
            3)
                echo "Instalando con Docker..."

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
    echo "prueba"
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
