#!/usr/bin/env python3.5
# coding: utf-8
from __future__ import division

import os
import sys
import subprocess
import logging
import tweepy
import time
import random

import json
import requests
from requests_oauthlib import OAuth1

from time import gmtime, strftime
from modules import  bifrost
from modules import finna, roeoa, skutr, geta

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
pic_folder = '/home/pi/Bots/EdenBot/cam/'

    
def timeNow():
    return strftime("day%Y_%m_%d_time%H_%M_%S", time.localtime())    



#Prints The Header
def header():
    with open("settings/titre/EdenBotTitre.txt",'r') as f:
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



def hardware_sample_status():
    #Takes Pic and creates status
    TLname = 'hardware_sample'
    finna.set_servo(1400,1300)
    pic = finna.take_picture(TLname)
    DataSample = finna.DataSample(1)
    status = roeoa.create_hardware_status(DataSample)
    time.sleep(3)
    #Tweet pic and status
    roeoa.tweet_picture_status(pic, status)
    skutr.save_hardware_sample(DataSample)
    finna.clean_pic(TLname)

def timelapse_sample_status(duration, TLname):
    #creates and shots the timelapse
    timelapse = finna.ParametricTimelapse(duration, TLname)
    TLgif = timelapse.run()
    DataSample = finna.DataSample(3)

    #post gif on twitter
    roeoa.chunk_tweet_gif(TLgif, roeoa.create_data_status(DataSample))

    
    

def main():
    header()
    bifrost.main()
    
    #Simple daily routine
    geta.oracle_status()
    geta.timelapse_sample_status(0.5, 'FrontStill_1')
    
    
    #delete all old files
    #print('Clean previous files')    
    #remove_all_files_from_folder_list([pic_folder+'timelapse/inPic',pic_folder+'timelapse/outGif'])
    
 
    #timelapse = finna.Timelapse(0.5, name='ZenithRightStill_1')
    #TLgif = timelapse.run()

    #post gif on twitter
    #roeoa.chunk_tweet_gif(get_last_image_from_folder(pic_folder+'timelapse/outGif'), roeoa.create_random_hashtag_status())
    #roeoa.chunk_tweet_gif(TLgif, roeoa.create_informedStatus())


    #create a data sample instance
    #roeoa.tweet_status(roeoa.create_dataStatus(DS))
    #skutr.updade_readings()
    
    #timelapse_sample_status(1, 'zenithal3')
    
    #hardware_sample_status()
   # skutr.return_db_tl()
    print('All EdenBot Processes over')
    header()




if __name__ == "__main__":
    # Uncomment to enable debug output.
    #logging.basicConfig(level=logging.DEBUG)
    main()
