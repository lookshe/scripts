import RPi.GPIO as GPIO
import time
import thread
import subprocess

# pin-setup
GPIO.setmode(GPIO.BOARD)
led_pin = 12
blk_pin = 16
red_pin = 18

# set volume
cmd_amixer1 = 'amixer -c 0 set PCM 98%'
cmd_amixer2 = 'amixer -c 0 set Speaker 98%'

# the process we want to start and its argument
cmd_player = 'mplayer'
arg_player = 'http://192.168.1.33:8000/mpd.ogg'
process = 0

def playerThreadFunc():
   # we need in every thread, so it is a global
   global process
   # kill if running
   if process != 0:
      if process.poll() == None:
         process.terminate()
         time.sleep(1)
   # turn on led
   GPIO.output(led_pin, True)
   # start process and wait for termination
   process = subprocess.Popen([cmd_player, arg_player])
   process.wait()
   # turn off led
   GPIO.output(led_pin, False)

# callback function
def callBackFunc(channel=0):
   thread.start_new_thread(playerThreadFunc, ())

# init
GPIO.setup(led_pin, GPIO.OUT)
GPIO.setup(blk_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(red_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# add event
GPIO.add_event_detect(blk_pin, GPIO.RISING, callback=callBackFunc, bouncetime=300)

while True:
   subprocess.call(cmd_amixer1, shell=True)
   subprocess.call(cmd_amixer2, shell=True)
   thread.start_new_thread(playerThreadFunc, ())
   GPIO.wait_for_edge(red_pin, GPIO.FALLING)
   break

# clean
GPIO.cleanup()

subprocess.call('shutdown -h now', shell=True)
