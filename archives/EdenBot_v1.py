#!/usr/bin/env python3.5
# coding: utf-8
from __future__ import division

import os
import sys
import subprocess
import logging
import tweepy
import time

import json
import requests
from requests_oauthlib import OAuth1

from time import gmtime, strftime
from modules import finna

# Import the PCA9685 module.
import Adafruit_PCA9685




api_key ='rCrJ81IdcyJwGVUlvdXq8SriP'
secret_key ='nYK9b2NCsSA6NnrF2Ti4ohH7kymytGgLd0T0TIhGq0RaCC9pHH'
token ='1239585197097656320-GahDA6AgvKZJqUMrGHWgJTdnwWZGMC'
secret_token ='FF42wZDIcFi54iaofIhKXJyRRNgFKcqADfT723dXAg2dD'




abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

pic_folder = dname+'/cam/'
image_format =[".jpg", ".jpeg", ".gif"]

MEDIA_ENDPOINT_URL = 'https://upload.twitter.com/1.1/media/upload.json'
POST_TWEET_URL = 'https://api.twitter.com/1.1/statuses/update.json'


#Connects to tweeter API
auth = tweepy.OAuthHandler(api_key, secret_key)
auth.set_access_token(token, secret_token)
api = tweepy.API(auth)
api.wait_on_rate_limit = True


oauth = OAuth1(api_key,
  client_secret=secret_key,
  resource_owner_key=token,
  resource_owner_secret=secret_token)


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

# Set frequency to 60hz, good for servos.
pwm.set_pwm_freq(60)

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
    return strftime("day%Y_%m_%d_time%H_%M_%S", time.localtime())    



#Prints The Header
def header():
    with open("settings/EdenBotTitre.txt",'r') as f:
        header = f.read() 
    print(header)
    print("-------- -        "+timeNow()+"      - ---------")
    print("----------- -                                 - -------------") 
    print("----------- - - - - - - - - - - - - - - - - - - -------------\n\n")

def remove_all_files_from_folder_list(list):
    print(timeNow()+" --> Starting Cleaner")
    for folder in list :
        for dirpath, dirnames, files in os.walk(folder):
            for f in files :
                file_path = os.path.join(dirpath, f)
                os.remove(file_path)
                print("----> " + file_path + " removed")


def create_diagonal_timelapse(wait_time):
    print('Moving servo for 2DOF movement')    
    for i in range(90, 0, -1):
        pwm.set_pwm(4, 0, 590+i)
        pwm.set_pwm(5, 0, 175+(i*5))
        print('Servo 4 & 5 set to position ' + str(i))
        time.sleep(wait_time)
        take_picture()
    #create a gif and write on older file if there are more than one
    print('Making Gif')
    os.system('convert -delay 10 -loop 0 '+pic_folder+'timelapse/inPic/EdenPic*.jpg '+pic_folder+'timelapse/outGif/EdenRaw.gif')
    os.system('gifsicle -o3 -V --colors 128 --dither '+pic_folder+'timelapse/outGif/EdenRaw.gif -o '+pic_folder+'timelapse/outGif/Eden_'+timeNow()+'.gif')


def create_top_circle_timelapse(wait_time):  
    print('Moving servo for 1DOF movement')
    pwm.set_pwm(4, 0, 620)
    for i in range(650, 200, -5):
        pwm.set_pwm(5, 0, i)
        print('Servo 4 set to position ' + str(i))
        time.sleep(wait_time)
        take_picture()
    #create a gif and write on older file if there are more than one
    print('Making Gif')
    os.system('convert -delay 10 -loop 0 '+pic_folder+'timelapse/inPic/EdenPic*.jpg '+pic_folder+'timelapse/outGif/EdenRaw.gif')
    os.system('gifsicle -o3 -V -i --colors 128 --dither '+pic_folder+'timelapse/outGif/EdenRaw.gif -o '+pic_folder+'timelapse/outGif/Eden_'+timeNow()+'.gif')


def create_quick_zenithal_timelapse(wait_time):  
    print('Moving servo for 1DOF movement')
    pwm.set_pwm(5, 0, 400)
    for i in range(0, 180, 2):
        pwm.set_pwm(4, 0, 500+i)
        print('Servo 4 set to position ' + str(i))
        time.sleep(wait_time)
        take_picture()
    #create a gif and write on older file if there are more than one
    print('Making Gif')
    os.system('convert -delay 10 -loop 0 '+pic_folder+'timelapse/inPic/EdenPic*.jpg '+pic_folder+'timelapse/outGif/EdenRaw.gif')
    os.system('gifsicle -o1 -f -V -i --colors 128 --dither '+pic_folder+'timelapse/outGif/EdenRaw.gif -o '+pic_folder+'timelapse/outGif/Eden_'+timeNow()+'.gif')



def create_mirror_timelapse(wait_time):
    print('Moving servo for 1DOF movement')
    pwm.set_pwm(4, 0, 410)
    for i in range(310, 490, 2):
        pwm.set_pwm(5, 0, i)
        print('Servo 5 set to position ' + str(i))
        time.sleep(wait_time)
        take_picture()
    #create a gif and write on older file if there are more than one
    print('Making Gif')
    os.system('convert -delay 10 -loop 0 '+pic_folder+'timelapse/inPic/EdenPic*.jpg '+pic_folder+'timelapse/outGif/EdenRaw.gif')    
    os.system('gifsicle -o3 -V --colors 128 --flip-vertical --dither '+pic_folder+'timelapse/outGif/EdenRaw.gif -o '+pic_folder+'timelapse/outGif/Eden_'+timeNow()+'.gif')


def take_picture():
  #    os.system("fswebcam -r 640x480 --set exposure=300 --set saturation=70 --set sharpness=250 --set brightness=80 --set contrast=50 --no-banner "+pic_folder+"timelapse/inPic/EdenPic_"+timeNow()+".jpg")

    #os.system("fswebcam -r 640x480 --set brightness=90 --set gamma=300 -set contrast=150 --set saturation=70 --set sharpness=250 --no-banner "+pic_folder+"timelapse/inPic/EdenPic_"+timeNow()+".jpg")
    os.system("fswebcam -r 640x480 --no-banner --set gamma=150 --set brightness=120 --set sharpness=5 --set contrast=15 "+pic_folder+"timelapse/inPic/EdenPic_"+timeNow()+".jpg")
    print('Taking picture at ' + timeNow())

    

def get_last_image_from_folder(folder):
    media_list = []
    for dirpath, dirnames, files in os.walk(folder):
        for f in files:
            media_list.append(os.path.join(dirpath, f))
    if not media_list:
        print("list empty")
        return None
    media = max(media_list, key=os.path.getctime)
    return media

#Calls Bash script to get system info
def temperatureinfo():
    #Gives CPU temperature
    cmd = '/opt/vc/bin/vcgencmd measure_temp'
    line = os.popen(cmd).readline().strip()
    temperature = line.split('=')[1].split("'")[0]
    return temperature

def create_status():
    status = 'View of New Eden the '+ strftime("%d/%m at %H:%M", time.localtime()) + '. CPU temperature is '+ temperatureinfo() +'°. --> #Gardening #BotArt #Python #Timelapse #CyberBotanic'
    return status

def chunk_tweet_last_gif():
      videoTweet = GifTweet(get_last_image_from_folder(pic_folder+'timelapse/outGif'))
      videoTweet.upload_init()
      videoTweet.upload_append()
      videoTweet.upload_finalize()
      videoTweet.tweet()

def tweet_last_gif():
                                
    media = get_last_image_from_folder(pic_folder+'timelapse/outGif')
    print(media[0])
    file = open(media, 'rb')
    r1 = api.media_upload(filename=media, file=file)
    media_id =[r1.media_id_string]

    status = "My view the "+ strftime("m/%d at %H:%M", time.localtime()) + " --> #Design #BotArt #Python #Timelapse #CyberBotanic"
    api.update_with_media(media_id, status)


def main():
    header()
    
    
    #delete all old files
    print('Clean previous files')    
    remove_all_files_from_folder_list([pic_folder+'timelapse/inPic',pic_folder+'timelapse/outGif'])
    
    print('Setting front view')    
    pwm.set_pwm(4, 0, 330)
    pwm.set_pwm(5, 0, 400)
    time.sleep(2)

    timelapse = finna.ParametricTimelapse(0.001, 'circle1')
    timelapse.run()

    #post gif ont twitter
  #  chunk_tweet_last_gif()





    print('All EdenBot Processes over')
    header()









class GifTweet(object):


    def __init__(self, file_name):
        '''
        Defines video tweet properties
        '''
        self.gif_filename = file_name
        self.total_bytes = os.path.getsize(self.gif_filename)
        self.media_id = None
        self.processing_info = None


    def upload_init(self):
        '''
        Initializes Upload
        '''
        print('INIT')

        request_data = {
          'command': 'INIT',
          'media_type': 'image/GIF',
          'total_bytes': self.total_bytes,
          'media_category': 'tweet_GIF'
        }

        req = requests.post(url=MEDIA_ENDPOINT_URL, data=request_data, auth=oauth)
        media_id = req.json()['media_id']

        self.media_id = media_id

        print('Media ID: %s' % str(media_id))


    def upload_append(self):
        '''
        Uploads media in chunks and appends to chunks uploaded
        '''
        segment_id = 0
        bytes_sent = 0
        file = open(self.gif_filename, 'rb')

        while bytes_sent < self.total_bytes:
            chunk = file.read(4*1024*1024)

            print('APPEND')

            request_data = {
            'command': 'APPEND',
            'media_id': self.media_id,
            'segment_index': segment_id
            }

            files = {
            'media':chunk
            }

            req = requests.post(url=MEDIA_ENDPOINT_URL, data=request_data, files=files, auth=oauth)

            if req.status_code < 200 or req.status_code > 299:
                print(req.status_code)
                print(req.text)
                sys.exit(0)

            segment_id = segment_id + 1
            bytes_sent = file.tell()

            print('%s of %s bytes uploaded' % (str(bytes_sent), str(self.total_bytes)))

        print('Upload chunks complete.')


    def upload_finalize(self):
        '''
        Finalizes uploads and starts processing
        '''
        print('FINALIZE')

        request_data = {
          'command': 'FINALIZE',
          'media_id': self.media_id
        }

        req = requests.post(url=MEDIA_ENDPOINT_URL, data=request_data, auth=oauth)
        print(req.json())

        self.processing_info = req.json().get('processing_info', None)
        self.check_status()


    def check_status(self):
        '''
        Checks processing status
        '''
        if self.processing_info is None:
          return

        state = self.processing_info['state']

        print('Media processing status is %s ' % state)

        if state == u'succeeded':
          return

        if state == u'failed':
          sys.exit(0)

        check_after_secs = self.processing_info['check_after_secs']

        print('Checking after %s seconds' % str(check_after_secs))
        time.sleep(check_after_secs)

        print('STATUS')

        request_params = {
          'command': 'STATUS',
          'media_id': self.media_id
        }

        req = requests.get(url=MEDIA_ENDPOINT_URL, params=request_params, auth=oauth)

        self.processing_info = req.json().get('processing_info', None)
        self.check_status()


    def tweet(self):
        '''
        Publishes Tweet with attached media
        '''
        request_data = {
          'status': create_status(),
          'media_ids': self.media_id
        }

        req = requests.post(url=POST_TWEET_URL, data=request_data, auth=oauth)
        print(req.json())



if __name__ == "__main__":
    # Uncomment to enable debug output.
    #logging.basicConfig(level=logging.DEBUG)
    main()
