#!/usr/bin/env python3.5
# coding: utf-8

#"Bifrost" - The rainbow that connects the worlds
#This file parses the config and settings files
#It holds the connections beetween the differents modules
#Holds the system, the network, the hardware and software together
#Discuss with the user and input order to EdenBot

from __future__ import division

# Import generic modules
import os
import sys
import subprocess
import configparser
import argparse


abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)


#Reads configuration file and holds all settings for the bot to function.
config = configparser.ConfigParser()
config_file = '/home/pi/Bots/EdenBot/settingsEdenBot.ini'
config.read(config_file)

# read configs from file
twitter_config = config['TwitterInfo']
api_key = twitter_config['api_key']
secret_key = twitter_config['secret_key']
token = twitter_config['token']
secret_token = twitter_config['secret_token']
media = twitter_config['media_endpoint']
post = twitter_config['post_url']

eden = config['EdenBot']
pic_folder = eden['picfolder']
	
speech = config['Speech']
mainhash = speech['mainhash']
randomhash = speech['randomhash'].split('\n')
greenhash = speech['greenhash'].split('\n')
divinehash = speech['divinehash'].split('\n')
bothash = speech['bothash'].split('\n')
blessings = speech['blessings'].split('\n')

tl = config['Timelapse']
frames = int(tl['total_frames'])
delay = tl['gif_delay']
colors = tl['gif_colors']

ap = config['AirParif']
nox = int(ap['station_nox'])
no2 = int(ap['station_no2'])
o3 = int(ap['station_o3'])
airparif = ap['airparif_url']
aprequest = ap['request']
polluants = ap['polluants'].split('\n')

h = config['Hardware']
hygro = h['hygro_pin']
	
d = config['DataBase']
db = d['base_name']	
	
from modules import finna, roeoa, geta


#Prints The Header
def header():
    with open(dname+"/../settings/titre/BifrostTitre.txt",'r') as f:
        header = f.read() 
    print(header)
	
def present_dict(standard_dict):
	for i in range(0, len(standard_dict)):
		print("["+str(i+1)+"] - "+ str(list(standard_dict)[i]))
	index = int(input("--> Select an item by typing his number :"))-1
	#selected = {list(standard_dict)[index]:standard_dict[list(standard_dict)[index]]}

	selected = [list(standard_dict)[index],standard_dict[list(standard_dict)[index]]]
	print("--> Returning "+ str(selected))
	return(selected)

def parse_arguments():
	parser = argparse.ArgumentParser(description="EdenBot.py manages the 7 modules")


	parser.add_argument("--status", action="store_true",
						help="will return and store into database cpu temp, gh temp and gh humidity")
	parser.add_argument("--setservo", action="store_true",
						help="set manually pan and tilt for camera")
	parser.add_argument("--timelapse", action="store_true",
						help="starts a new timelapse and store hardware")
	parser.add_argument("--oracle", action="store_true",
						help="tweet a famous tree oracle")
	args = parser.parse_args()
	if args.status:
		geta.hardware_sample_status()
	if args.setservo:
		define_servo()
	if args.timelapse:
		start_timelapse()
	if args.oracle:
		start_timelapse()

def define_status():
	geta.hardware_sample_status()

def define_servo():
	tilt = int(input("--> Enter TILT value :"))
	pan = int(input("--> Enter PAN value :"))
	finna.set_servo(tilt, pan)
	
def start_timelapse():
	duration = float(input("--> Enter the timelapse duration (in days) :"))
	TLname = str(input("--> Enter the timelapse type :"))
	geta.timelapse_sample_status(duration, TLname)

def define_status():
	geta.oracle_status()

def main():
	header()
	parse_arguments()
	
	
if __name__ == "__main__":
    # Uncomment to enable debug output.
    #logging.basicConfig(level=logging.DEBUG)
    main()
	
