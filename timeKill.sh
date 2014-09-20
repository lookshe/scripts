#/bin/bash

ende() {
   printf "\b \b"
   echo "$0 cancelled"
   # show input again
   stty echo
   exit 10
}

trap ende 2

usage() {
   echo "usage: $0 (processname|pid) time(hh:mm)"
   exit 1
}

output() {
   if [ $# -eq 1 ]
   then
      printf "$1"
      sleep 3
      printf "\b \b"
   fi
}

rotate() {
   rotate_help
   rotate_help
}

rotate_help() {
   output "|"
   output "/"
   output "-"
   output "\\"
}

# exit if not 2 arguments are given
if [ $# -ne 2 ]
then
   usage
fi

process="$1"
time="$2"
actTime="$(date +%H:%M)"
# exit if given time is not correct
if [ "$(echo "$time" | sed 's/[01][0123456789]:[012345][0123456789]\|[2][0123]:[012345][0123456789]//g')" != "" ]
then
   usage
fi

# select if PID or processname is given
#  hopefully no process is named only with numbers
if [ "$(echo "$process" | sed s/[0123456789]//g)" = "" ]
then
   isPID="true"
else
   isPID="false"
fi

# exit if processname or PID is not single-valued
if [ $(ps -A | grep $process | wc -l) -ne 1 ]
then
   echo "no process found or too many found! ($process)"
   exit 2
fi

# convert processname to PID if neccessary
if [ "$isPID" = "false" ]
then
   process="$(ps -A | grep $process | awk '{print $1}')"
fi

# turn of showing input
stty -echo

# endless loop ;-)
while [ 1 ]
do
   # exit if process already stopped
   if [ $(ps -A | awk '{print $1}' | grep $process | wc -l) -ne 1 ]
   then
      echo
      echo "process already stopped"
      stty echo
      exit 0
   fi

   # if time has reached, then kill process and exit
   if [ "$actTime" = "$time" ]
   then
      kill "$process"
      echo
      echo "process killed succesfully"
      stty echo
      exit 0
   # output to see that the script works
   # checks every 48 sec
   else
      rotate
      rotate
   fi
   actTime=$(date +%H:%M)
done
