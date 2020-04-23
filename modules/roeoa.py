#!/usr/bin/env python3.5
# coding: utf-8

#"Roeoa" - Conversation, to talk
#This file contains the classes used to express to the world
#it will log through network accounts and post
#it will create the sentences of EdenBot
#it will send messages through lcd, led and buzzer

from __future__ import division

# Import generic modules
import time
import os
import sys
import subprocess
import tweepy
import time
import json
import requests
import random
import math
from requests_oauthlib import OAuth1

from time import gmtime, strftime
from modules import finna, bifrost, skutr, geta

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

pic_folder = bifrost.pic_folder
hashtags = bifrost.randomhash
greenhash = bifrost.greenhash
bothash = bifrost.bothash
divinehash = bifrost.divinehash


mainhash = '#' + bifrost.mainhash +" "

api_key =bifrost.api_key
secret_key =bifrost.secret_key
token = bifrost.token
secret_token =bifrost.secret_token

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

MEDIA_ENDPOINT_URL = bifrost.media
POST_TWEET_URL = bifrost.post
blessings = bifrost.blessings

#Connects to tweeter API
auth = tweepy.OAuthHandler(api_key, secret_key)
auth.set_access_token(token, secret_token)
api = tweepy.API(auth)
api.wait_on_rate_limit = True

oauth = OAuth1(api_key,
  client_secret=secret_key,
  resource_owner_key=token,
  resource_owner_secret=secret_token)

#Prints The Header
def header():
    with open(dname+"/../settings/titre/RoeoaTitre.txt",'r') as f:
        header = f.read() 
    print(header)

def select_random_hashtags(hlist, qty):
	selection = random.sample(hlist, qty)
	HT = ''
	for s in selection:
		HT+=('#'+s+' ')
	return HT

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

def create_data_status(DS):
    # Data order: cpu_temp, gh_temp, humidity, nox, no2, o3, atmo, date
    # DS = finna.DataSample()
    status = 'The pollution level in Paris is valued '+ str(getattr(DS, 'atmo')) +'/10 by @Airparif for the '+strftime("%d/%m/%y", time.localtime())+', with '+str(getattr(DS, 'nox'))+'µg/m3 of NOx, '+str(getattr(DS, 'no2'))+'µg/m3 of NO2 & '+str(getattr(DS, 'o3'))+'µg/m3 of O3. My greenhouse temperature is '+ str(getattr(DS, 'gh_temp'))+'°C and humidity '+str(getattr(DS, 'humidity'))+'%. My CPU tempereature is '+str(getattr(DS, 'no2'))+'°C. --> #pollution #Paris '+select_random_hashtags(hashtags, 1)
    return status

def create_hardware_status(DS):
    status = 'The greenhouse temperature is '+str(getattr(DS, 'gh_temp'))+'°C. Humidity is '+str(getattr(DS, 'humidity'))+'%. CPU temperature is '+ str(getattr(DS, 'cpu_temp')) +'°C. '+mainhash+' '+select_random_hashtags(4)
    return status

def create_simple_status():
    status = 'View of New Eden the '+ strftime("%d/%m at %H:%M", time.localtime()) + '. CPU temperature is '+ finna.take_cputemp() +'°. --> '+mainhash+' '+select_random_hashtags(2)
    return status

def create_random_hashtag_status():
    status = select_random_hashtags(5)
    return status
    
def create_oracle_status(FT):
    #self.name, self.N3, self.alias, self.kind, self.plant_name, self.description
    status = random.choice(blessings) +" \""+ str(getattr(FT, 'name')) + "\", the " +str(getattr(FT, 'kind')) 
    if getattr(FT, 'alias') is not None:
        alias = ""
        aliases = str(getattr(FT, 'alias')).split(",")
        if len(aliases)>1 :
            for i in range(0, len(aliases)-1):
                alias += aliases[i] + ", "
            alias = alias[:-2]
            alias += " or" + aliases[len(aliases)-1]
        else :
            alias = str(getattr(FT, 'alias'))
        status += ", also known as " + alias
    status += " " + mainhash + select_random_hashtags(hashtags, 2) + select_random_hashtags(divinehash, 3)
    if getattr(FT, 'plant_name') is not None:
        status += "/"+ select_random_hashtags(hashtags, 5) +"The famous tree \""+getattr(FT, 'name')+"\" belongs to the family of the " + getattr(FT, 'plant_name') + ". "+ getattr(FT, 'description')
    return status

def chunk_tweet_last_gif():
      Tweet = GifTweet(get_last_image_from_folder(pic_folder+'timelapse/outGif'))
      Tweet.upload_init()
      Tweet.upload_append()
      Tweet.upload_finalize()
      Tweet.tweet()

def chunk_tweet_gif(gifPath, status_string):
      Tweet = GifTweet(gifPath, status_string)
      Tweet.upload_init()
      Tweet.upload_append()
      Tweet.upload_finalize()
      Tweet.tweet()
      skutr.save_text_archive(status_string)
      skutr.update_VisualSample_url()

def tweet_multipart_status_by_words(status):
    header()
    max_length = 270
    #parts = math.ceil(len(s)/max_length)
    words = status.split()
    part_words = ""
    new_s = []
    i = -1
    statuses = status.split("/")
    print(str(statuses))
    for s in statuses:
        new_s.append("")
        i += 1
        words = s.split()
        for w in words:
            print(w + str(len(w)))
            print(new_s[i])
            print(str(len(new_s[i])))

            if (len(new_s[i])+len(w)) < max_length:
                new_s[i] += w + " "
            else :
                new_s[i] += w + "..."
                i += 1
                new_s.append("..."+w + " ")

def tweet_multipart_status_by_sentence(status):
    header()
    max_length = 270
    i = -1
    statuses = status.split("/")
    new_s = []
    for s in statuses:
        new_s.append("")
        i += 1
        sentences = s.split(". ")
        j = 1
        for s in sentences:
            if (len(new_s[i])+len(s)) < max_length:
                if j == 1 :
                    new_s[i] += s
                else : 
                    new_s[i] += ". " + s
                j += 1                
            else :
                i += 1
                new_s.append(s)

    statuses = new_s
    
    if len(statuses) < 1:
        print('-----> Error : no satus - no tweet')
    if len(statuses) == 1:
        api.update_status(statuses[0])
        print('Status : ' + statuses[0])
    if len(statuses) > 1:
        print('Status [1] : '+ statuses[0])
        status_object = api.update_status(statuses[0])
        for i in range(1, len(statuses)) :
            time.sleep(3)
            print('Status ['+str(i+1)+'] : '+ statuses[i])
            status_object = api.update_status(statuses[i], in_reply_to_status_id = status_object.id)


def tweet_picture_status(pic, status):
    header()
    print('Status : '+ status)
    print('Media : ' + pic)
    '''file = open(pic, 'rb')
    name = os.path.basename(pic)
    print(name)
    r1 = api.media_upload(filename=name, file=file)
    media_id =[r1.media_id_string]
    print(media_id)'''
    api.update_with_media(pic, status)


def tweet_status(status):
    header()
    print(status)
    api.update_status(status)


class GifTweet(object):


    def __init__(self, file_name, status_string):
        '''
        Defines video tweet properties
        '''
        header()
        self.gif_filename = file_name
        self.total_bytes = os.path.getsize(self.gif_filename)
        self.media_id = None
        self.processing_info = None
        self.status_string = status_string


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
          'status': self.status_string,
          'media_ids': self.media_id
        }

        req = requests.post(url=POST_TWEET_URL, data=request_data, auth=oauth)
        print(req.json())



