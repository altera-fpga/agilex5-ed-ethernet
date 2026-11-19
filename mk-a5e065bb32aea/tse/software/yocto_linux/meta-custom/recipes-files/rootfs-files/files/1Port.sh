#!/bin/sh
echo -e "Programming the Basic IP address..."

arr_eth1=($(awk -F: '/eth1/ {print $1}' /proc/interrupts))
echo "8" > /proc/irq/${arr_eth1[0]}/smp_affinity && echo "8" > /proc/irq/${arr_eth1[1]}/smp_affinity

echo -e "Flushing old IPv4 and IPv6 addresses and routes"
ip addres flush eth1 && ip route flush dev eth1
ip -6 addres flush eth1 && ip -6 route flush dev eth1

if [ -z "$1" ]; then
	echo -e "Running script for Devkit $DEVKIT."
else
	if [ "$1" == 1 ] || [ "$1" == 2 ]; then
		echo -e "Setting DEVKIT to $1."
	else
		echo -e "Wrong devkit value. Usage: $0 <1/2>."
		exit
	fi
	export DEVKIT=$1
	echo -e "Running script for Devkit $DEVKIT."
fi

if [ -z "$DEVKIT" ]; then
	echo -e "Devkit value not set. Some confguration may not be set. Please rerun after setting the shell variable <DEVKIT> to 1 or 2."
else
	if [ "$DEVKIT" == 1 ]; then
		ip link set eth1 up && ip addr add 192.168.121.1 dev eth1 && ip route add 192.168.121.0/24 dev eth1 src 192.168.121.1
	elif [ "$DEVKIT" == 2 ]; then
		ip link set eth1 up && ip addr add 192.168.121.2 dev eth1 && ip route add 192.168.121.0/24 dev eth1 src 192.168.121.2
	else
		echo -e "Wrong Devkit value. Please set hell variable <DEVKIT> to 1 or 2."
	fi
fi

ip addr | grep ether

echo -e "Programming the IPV6 rules - Port 0"
echo -e "Setting IPv6 local addresses"
if [ -z "$DEVKIT" ]; then
	echo -e "Devkit value not set. Some IPV6 confguration may not be set. Please rerun after setting the shell variable <DEVKIT> to 1 or 2."
else
	if [ "$DEVKIT" == 1 ]; then
		ip -6 addr add 2001:db8:abcd:0012::1/64 dev eth1 && ip link set dev eth1 up
		sleep 2
		ip -6 route add 2001:db8:abcd:0012::1/64 dev eth1 src 2001:db8:abcd:0012::1
	elif [ "$DEVKIT" == 2 ]; then
		ip -6 addr add 2001:db8:abcd:0012::2/64 dev eth1 && ip link set dev eth1 up
		sleep 2
		ip -6 route add 2001:db8:abcd:0012::2/64 dev eth1 src 2001:db8:abcd:0012::2
	else
		echo -e "Wrong Devkit value. Please set shell variable <DEVKIT> to 1 or 2."
	fi
fi

echo -e "Configuration for Devkit $DEVKIT set"
