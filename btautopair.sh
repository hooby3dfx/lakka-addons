#!/bin/bash

#script to run on system boot that enables bluetooth, and pairs any available game controllers
#that are available during the ~1-2 mins that the script runs for.

#requires empty (http://empty.sourceforge.net/)
EMPTYBIN='/storage/empty'


#string utils that work on busybox...
stringContain() { [ -z "${2##*$1*}" ]; }
strindex() { 
  x="${1%%$2*}"
  [ "$x" = "$1" ] && echo -1 || echo ${#x}
}


#systemctl status bluetooth

#make sure bluetooth is up and running.
touch /storage/.cache/services/bluez.conf
systemctl enable bluetooth
systemctl start bluetooth

echo "bluetooth up and running"

#start the bluetooth interactive console
$EMPTYBIN -f bluetoothctl
sleep 2

#listen for prompt and start scan
$EMPTYBIN -s "scan on\n"

$EMPTYBIN -w "Discovery started"

echo "bluetooth scanning"

#look for a bunch of messages... might want to tweak this
for i in `seq 1 20`
do
	echo "waiting for event $i..."
	#look for a NEW, waiting up to 10s
	ONELINE="$($EMPTYBIN -r -t 10)"
	echo "saw $ONELINE"
	if [ -z "$ONELINE" ]; then
		#echo "empty string"
		#hack
		ONELINE="cheese"
	fi

	if stringContain "NEW" "$ONELINE" && stringContain "Device " "$ONELINE"; then
		echo "processing device"
		#capture MAC
		MAC_INDEX=$(strindex "$ONELINE" "Device")
		#the MAC address is offset 7 chars from the word Device...
		MAC_INDEX=$((MAC_INDEX + 7))
		#mac is 17 chars long
  		MACADDR=${ONELINE:$MAC_INDEX:17}

		#for any new MAC, request info
		echo "requesting info for $MACADDR"
		$EMPTYBIN -s "info $MACADDR\n"

		#listen for "Icon: input-gaming"
		ERRORCODE="$($EMPTYBIN -w "input-gaming" -t 5)"
		ERRORCODE=$?
		echo "ERRORCODE $ERRORCODE"

		if [ "$ERRORCODE" -eq 1 ]; then
			
			#pair
			echo "going to pair"
			$EMPTYBIN -s "pair $MACADDR\n"
			sleep 2

			#connect
			echo "going to connect"
			$EMPTYBIN -s "connect $MACADDR\n"
			sleep 2

			#trust
			echo "going to trust"
			$EMPTYBIN -s "trust $MACADDR\n"
			sleep 2

			#sleep a little more for good measure...
			sleep 3
		else
			echo "not a gamepad"
		fi

	else
		echo "not a new device event"
	fi
done

#exit! 
echo "exiting"
$EMPTYBIN -s "exit\n"
sleep 5
killall bluetoothctl
