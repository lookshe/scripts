#!/bin/bash

#device=`udevadm info --query=path --name=/dev/backup --attribute-walk | egrep "looking at parent device" | head -1 | sed -e "s/.*looking at parent device '\(\/devices\/.*\)\/.*\/host.*/\1/g"`

#echo on > /sys$device/power/level

mount -t ext3 /dev/backup /media/backup

if [ -e /tmp/deletebackup ]
then

   rsync -a --delete /media/usb-3 /media/backup
   rsync -a --delete /home/lookshe /media/backup

else

   rsync -a /media/usb-3 /media/backup
   rsync -a /home/lookshe /media/backup

fi

rsync -a /etc /media/backup

if [ ! -e /tmp/keepbackup ]
then

   umount /media/backup

   sync

   sdparm --command=sync /dev/backup > /dev/null
   sdparm --command=stop /dev/backup > /dev/null

#   deviceid=`udevadm info --query=path --name=/dev/backup --attribute-walk | egrep "looking at parent device" | head -1 | sed -e "s/.*looking at parent device '\/devices\/.*\/\(.*\)\/.*\/host.*/\1/g"`

#   echo -n "$deviceid" > /sys/bus/usb/drivers/usb/unbind

#   echo suspend > /sys$device/power/level

fi
