#!/bin/bash

usage() {
   echo "Usage: $0 [-v] [-l]"
   exit 0
}

### default values ###

# folder for pictures
picdir="/home/lookshe/Bilder/d5100"

# server path #
serverpath="192.168.1.33:/home/lookshe/bilder/"

nicelevel=19

verbose=0
bwlimit=0

# parse arguments #
for arg in "$@"
do
case $arg in
   -v)
      verbose=1
   ;;
   -l)
      bwlimit=1
   ;;
   *)
      usage
   ;;
esac
done

nice -n $nicelevel rsync -a -r $(if [ $verbose -eq 1 ]; then echo "-v"; fi) $(if [ $bwlimit -eq 1 ]; then echo "--bwlimit 1000"; fi) --progress "$picdir" "$serverpath"
