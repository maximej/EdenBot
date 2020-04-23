
from __future__ import division
import time
import os
import sys
import subprocess
from time import gmtime, strftime

# Import the PCA9685 module.
import Adafruit_PCA9685


# Uncomment to enable debug output.
#import logging
#logging.basicConfig(level=logging.DEBUG)

# Initialise the PCA9685 using the default address (0x40).
pwm = Adafruit_PCA9685.PCA9685()

# Alternatively specify a different address and/or bus:
#pwm = Adafruit_PCA9685.PCA9685(address=0x41, busnum=2)

# Configure min and max servo pulse lengths
servo_min = 0  # Min pulse length out of 4096
servo_max = 4096 # Max pulse length out of 4096

# Helper function to make setting a servo pulse width simpler.
def set_servo_pulse(channel, pulse):
    pulse_length = 1000000    # 1,000,000 us per second
    pulse_length //= 60       # 60 Hz
    print('{0}us per period'.format(pulse_length))
    pulse_length //= 4096     # 12 bits of resolution
    print('{0}us per bit'.format(pulse_length))
    pulse *= 1000
    pulse //= pulse_length
    pwm.set_pwm(channel, 0, pulse)
    
    
def timeNow():
    return strftime("day%Y-%m-%d_time%H_%M_%S", time.localtime())    

# Set frequency to 60hz, good for servos.
pwm.set_pwm_freq(60)


print('Setting front view')    
pwm.set_pwm(4, 0, 330)
pwm.set_pwm(5, 0, 400)
time.sleep(2)

print('Moving servo for 1DOF movement')
pwm.set_pwm(5, 0, 400)
for i in range(0, 180, 2):
    pwm.set_pwm(4, 0, 500+i)
    print('Servo 4 set to position ' + str(i))
    time.sleep(1)
    print('Taking picture at ' + timeNow())
    os.system("fswebcam -r 640x480 --no-banner /home/pi/Bots/EdenBot/cam/timelapse/inPic/EdenPic"+timeNow()+".jpg")

#create a gif and delete older file if there are more than one

os.system('convert -delay 10 -loop 0 /home/pi/Bots/EdenBot/cam/timelapse/inPic/EdenPic*.jpg /home/pi/Bots/EdenBot/cam/timelapse/outGif/Eden.gif')

#delete all jpg files

#post gif ont twitter