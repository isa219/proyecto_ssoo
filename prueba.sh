#!/bin/bash

if [ "$#" == "0" ]; then

        echo "testing: faltan parametros"
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

                echo "testing [ install { ansible | docker | comandos } ] [ unistall ] [ start ] [ stop ] [ edit { ambito direccion_red mascara IP_inicio IP_final IP_gateway IP_DNS | reserva IP MAC | puerto_escucha puerto } ] [ --help ] [ info ]"

        elif [ "$1" == "info" ]; then

                ip=$(ip -c a | tail -6 | grep -E "[0-9]{3}\." | cut -d" " -f6)
                estado=$(service isc-dhcp-server status | grep "Active:" | cut -d" " -f7)

                echo "Dirección IP de la maquina: $ip"
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

			apt install isc-dhcp-server -y
			echo "Instalacion completada"

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

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                        if [ "$comprobar_ip" == "" ]; then

                                echo "Íntroduce una dirección IP correcta"

			else

				echo "testing: mal faltan argumentos"
                        	echo "Pruebe 'testing --help' para más informacíon"

			fi

		elif [ "$2" == "ambito" ]; then

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
			if [ "$comprobar_ip" == "" ]; then

				echo "Íntroduce una dirección de red correcta"

			else

				echo "testing: mal faltan argumentos"
                                echo "Pruebe 'testing --help' para más informacíon"

			fi

		elif [ "$2" == "puerto_escucha" ]; then

                        sed -i "17s/.*/INTERFACESv4='$3'/" /etc/default/isc-dhcp-server

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

			comprobar_ip=$(echo $3 | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$")
                	if [ "$comprobar_ip" == "" ]; then

                        	echo "Íntroduce una dirección IP correcta"

			else

                        	comprobar_mac=$(echo $4 | grep -E "^([0-9]{2}\:){5}[0-9]{2}$")
				if [ "$comprobar_mac" == "" ]; then

					echo "Introduce una dirección MAC correcta"

				else

					sed -i "84s/.*/  fixed-address $3/" /etc/dhcp/dhcpd.conf
					sed -i "83s/.*/  hardware ethernet $4/" /etc/dhcp/dhcpd.conf

                                	echo "Dirección IP de reserva modificada con exito"
				fi
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
									sed -i "62s/.*/};/" /etc/dhcp/dhcpd.conf
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
