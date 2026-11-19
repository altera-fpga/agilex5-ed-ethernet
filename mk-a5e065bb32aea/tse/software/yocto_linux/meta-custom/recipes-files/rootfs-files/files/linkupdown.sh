#!/bin/sh

if [ -z "$DEVKIT" ]; then
        echo -e "Devkit value not set. Please rerun after setting the shell variable <DEVKIT> to 1 or 2."
	exit
fi

while [ 1 ]
do
	ip link set eth1 down
	sleep 5
	ip link set eth1 up
	sleep 5
	if [ "$(cat /sys/class/net/eth1/operstate)" = "up" ]; then
		echo 'eth1 is up'
	else
		echo 'eth1 is down. Quit'
		exit
	fi
	if [ "$DEVKIT" == 1 ]; then
		ip addr add 192.168.121.1 dev eth1
		ip route add 192.168.121.0/24 dev eth1 src 192.168.121.1
		ping -I eth1 192.168.121.2 -i 0.0001 -c 20000 -q &
	elif [ "$DEVKIT" == 2 ]; then
		ip addr add 192.168.121.2 dev eth1
		ip route add 192.168.121.0/24 dev eth1 src 192.168.121.2
		ping -I eth1 192.168.121.1 -i 0.0001 -c 20000 -q &
	fi
	sleep 5
done
