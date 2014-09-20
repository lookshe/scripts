#!/bin/bash

usage() {
   echo "Usage: $0 [--dev device] [--deleteaftercopy] [--noraw] [--nojpg] [--nomov] [--notimeinstamp]"
   exit 0
}

### default values ###

# device #
sddev=/dev/mmcblk0p1

# folder for pictures
picdir="/home/lookshe/Bilder/d5100"

# file endings #
end_jpg=".JPG"
end_raw=".NEF"
end_mov=".MOV"

# delete and timestamp #
deleteaftercopy=0
notimeinstamp=0

# which to copy #
copyraw=1
copyjpg=1
copymov=1

# we work with nice #
nicelevel=19

# parse arguments #
#for arg in "$@"
while [ "$1" != "" ]
do
case $1 in
   --deleteaftercopy)
      deleteaftercopy=1
   ;;
   --noraw)
      copyraw=0
   ;;
   --nojpg)
      copyjpg=0
   ;;
   --nomov)
      copymov=0
   ;;
   --notimeinstamp)
      notimeinstamp=1
   ;;
   --dev)
     shift
     sddev="$1"
   ;;
   *)
      usage
   ;;
esac
shift
done

# check for inserted card #
if [ ! -e "$sddev" ]
then
   echo "sd card not inserted!"
   exit 1
fi

# check if mounted #
#mountpoint=$(mount | grep "$sddev" | awk '{print $3}')
mountpoint=$(mount | grep "$sddev" | cut -d" " -f3- | sed 's/ type.*//')
if [ ! -e "$mountpoint" ]
then
   echo "sd card not mounted!"
   exit 2
fi

if [ $notimeinstamp -eq 1 ]
then
   stamp=$(date +%F)
else
   stamp=$(date +%F_%H-%M)
fi
copydir="$picdir/$stamp"

if [ -e "copydir" ]
then
   echo "$copydir already exists"
   exit 3
else
   mkdir "$copydir"
fi

echo "Start copying files:"

if [ $copyjpg -eq 1 ]
then
   mkdir "$copydir/pic"
   find "$mountpoint" -name "*$end_jpg" | while read file
   do
      nice -n $nicelevel cp -v "$file" "$copydir/pic"
      if [ $? -eq 0 -a $deleteaftercopy -eq 1 ]
      then
         nice -n $nicelevel rm "$file"
      fi
   done
fi

if [ $copyraw -eq 1 ]
then
   mkdir "$copydir/raw"
   find "$mountpoint" -name "*$end_raw" | while read file
   do
      nice -n $nicelevel cp -v "$file" "$copydir/raw"
      if [ $? -eq 0 -a $deleteaftercopy -eq 1 ]
      then
         nice -n $nicelevel rm "$file"
      fi
   done
fi

if [ $copymov -eq 1 ]
then
   mkdir "$copydir/mov"
   find "$mountpoint" -name "*$end_mov" | while read file
   do
      nice -n $nicelevel cp -v "$file" "$copydir/mov"
      if [ $? -eq 0 -a $deleteaftercopy -eq 1 ]
      then
         nice -n $nicelevel rm "$file"
      fi
   done
fi
