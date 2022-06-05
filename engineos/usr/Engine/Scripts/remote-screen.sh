#!/bin/sh

APPNAME=$1

while [ 1 ]
do
	echo "Entering remote screen app. Drives still mounted:"
	mount | grep ^/dev/s | sed 's/ type.*//'
	echo "End of drive list"

	/usr/bin/planck-remote-screen
	rsAppExitCode=$?
	
	if [ "$rsAppExitCode" -eq "0" ]; then
		echo "Remote Screen App exited"
		/bin/az01-usbmux-switch internal
		systemctl restart engine
		break
	fi
	echo "Remote Screen App crashed ($rsAppExitCode)"
done
