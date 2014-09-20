#!/bin/bash
#set -x

if [ $# -ne 8 ]
then
   echo "wrong argument count"
   exit 1
fi

url_map="$1"
url_map_filename="$(basename $url_map)"
download_map="$dir_maps/$url_map_filename"
url_poly="$2"
url_poly_filename="$(basename $url_poly)"
download_poly="$dir_poly/$url_poly_filename"
mapfile="$3"
wm_type="$4"
start_zoom="$5"
language="$6"
use_poly="$7"
output_subdir="$8"
stage_map="$dir_stage/$mapfile"
mkdir -p "$dir_output/$output_subdir/"
output_map="$dir_output/$output_subdir/$mapfile"


# cause of some timing problems we wait a random number of 1-10 seconds
sleep $[($RANDOM % 10) + 1]

# check if we need to download
if [ ! -e "$download_map" ]
then
   # wait if another process is downloading it
   if [ -e "$download_map.tmp" ]
   then
      while [ ! -e "$download_map" ]
      do
          sleep 10
      done
   # download if we are the only one
   else
      touch "$download_map.tmp"
      wget -q --limit-rate=$wget_limit_rate "$url_map" -O "$download_map.tmp"
      mv -f "$download_map.tmp" "$download_map"
   fi
fi

# download poly-file
wget -q --limit-rate=$wget_limit_rate "$url_poly" -O "$download_poly"

echo "start: $(date)" >> "$stage_map.time"
if [ "$use_poly" = "true" ]
then
   echo "command: $osmosis_executable --rb \"$download_map\" --bp clipIncompleteEntities=true file=\"$download_poly\" --mw file=\"$stage_map\" type=\"$wm_type\" map-start-zoom=\"$start_zoom\" preferred-language=\"$language\"" >> "$stage_map.time"
   $osmosis_executable --rb "$download_map" --bp clipIncompleteEntities=true file="$download_poly" --mw file="$stage_map" type="$wm_type" map-start-zoom="$start_zoom" preferred-language="$language" > "$stage_map.log" 2>&1
   ret=$?
else
   echo "command: $osmosis_executable --rb \"$download_map\" --mw file=\"$stage_map\" type=\"$wm_type\" map-start-zoom=\"$start_zoom\" preferred-language=\"$language\"" >> "$stage_map.time"
   $osmosis_executable --rb "$download_map" --mw file="$stage_map" type="$wm_type" map-start-zoom="$start_zoom" preferred-language="$language" > "$stage_map.log" 2>&1
   ret=$?
fi
echo "end: $(date)" >> "$stage_map.time"

if [ $ret -eq 0 ]
then
   mv -f "$stage_map" "$output_map"
   rm -f "$stage_map.log"
fi
