#!/bin/bash

if [ "$1" == "off" ]; then
	echo "Shutting down the Mac..."
	sudo shutdown -h now 
elif [ "$1" == "you" ]; then 
	echo "Rebooting the Mac..."
	sudo shutdown -r now
else 
	echo "Invalid command. Use 'off' to shutdown or 'you' to reboot."
fi
