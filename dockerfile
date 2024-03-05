FROM debian:latest

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install isc-dhcp-server -y

#RUN echo "#" >> /etc/dhcp/dhcpd.conf
#RUN echo "###### CONFIGURACIONES #########" >> /etc/dhcp/dhcpd.conf
#RUN echo "#" >> /etc/dhcp/dhcpd.conf
#RUN echo "subnet 192.168.5.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
#RUN echo "range 192.168.5.15 192.168.5.30;" >> /etc/dhcp/dhcpd.conf
#RUN echo "option routers 192.168.5.254;" >> /etc/dhcp/dhcpd.conf
#RUN echo "option domain-name-servers 8.8.8.8;" >> /etc/dhcp/dhcpd.conf
#RUN echo "}" >> /etc/dhcp/dhcpd.conf

#RUN sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s3"/' /etc/default/isc-dhcp-server

COPY comando.sh /root/

CMD ["/bin/bash"]
