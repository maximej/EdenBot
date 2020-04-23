#!/usr/bin/env python3.5
# coding: utf-8

#"Geta" - To think, to decuce
#This file contains the functions that need many modules aggregated
#it takes decisions, calculates and processes data
#it prepares actions on the long term

from __future__ import division

# Import generic modules
import time
import os
import sys
import subprocess
import random

from time import gmtime, strftime
from modules import bifrost, finna, roeoa, skutr

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

#Prints The Header
def header():
    with open(dname+"/../settings/titre/GetaTitre.txt",'r') as f:
        header = f.read() 
    print(header)

def hardware_sample_status():
    #Takes Pic and creates status
    header()
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

def open_hardware_status():
    #Takes Pic and creates status
    header()
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
    header()
    timelapse = finna.Timelapse(duration, TLname)
    TLgif = timelapse.run()
    DataSample = finna.DataSample(3)

    #post gif on twitter
    roeoa.chunk_tweet_gif(TLgif, roeoa.create_data_status(DataSample))
    skutr.save_data_sample(DataSample)

def oracle_status():
    FT = FamousTree()
    status = roeoa.create_oracle_status(FT)
    roeoa.tweet_multipart_status_by_sentence(status)
    return status


class FamousTree:
    def __init__(self):
        header()
        self.name, self.N3, self.alias, self.kind, self.plant_name, self.description = skutr.load_famous_tree()





