#!/usr/bin/env python3.5
# coding: utf-8

#"Finna" - To discover, to find, to percieve
#This file contains the classes used to get information from the world
#meto data, camera shots, timelapses creation, hardware data input
#the classes shall save, interpret and store temporaly the data
#the classes shall act directly on the GPIO

from __future__ import division

# Import generic modules
import time
import os
import sys
import subprocess
import fnmatch
import requests
import json

from datetime import datetime
from time import gmtime, strftime
from modules import bifrost, skutr

# Import the Hardware module: PCA9685 servo, hygrometer, termometer,
# camera, photoresistance, 
import Adafruit_PCA9685
import Adafruit_DHT


# Global Variables

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

pic_folder = bifrost.pic_folder
hygro_pin = bifrost.hygro
total_frames = bifrost.frames

station_nox = bifrost.nox
station_no2 = bifrost.no2
station_o3 = bifrost.o3
airparif_url = bifrost.airparif

# Initialise the PCA9685 using the default address (0x40).
pwm = Adafruit_PCA9685.PCA9685()
    

# Generic Functions

def clean_pic(TLname):
    print(" --> Starting Cleaner for " + TLname)
    cleaned = 0
    for dirpath, dirnames, files in os.walk(pic_folder):
        for f in files :
            if fnmatch.fnmatch(f, 'EdenPic_'+TLname+'*'):
                file_path = os.path.join(dirpath, f)
                os.remove(file_path)
                cleaned += 1
                #print("----> " + file_path + " removed")
    print("----> " + str(cleaned) + " files removed")


def timeNow():
    return strftime("%-y_%m_%d_at%H_%M_%S", time.localtime())    

#Prints The Header
def header():
    with open(dname+"/../settings/titre/FinnaTitre.txt",'r') as f:
        header = f.read() 
    print(header)


#Perception functions
def take_air_data():
    print('-----> Starting request for open data to airparif')
    headers = {'Content-Type': 'application/json'}
    polluants = bifrost.polluants
    mes_request = bifrost.aprequest 
    station = station_nox
    result={}
    for pol in polluants : 
        if pol == 'nox':
            station = station_nox
        if pol == 'no2':
            station = station_no2        
        if pol == 'o3':
            station = station_o3
        params = {'service':'WFS', 'version':'1.0.0', 'request':'GetFeature', 'typeName':mes_request+pol, 'outputFormat':'application/json'}
        response = requests.get(airparif_url, params=params, headers=headers)
        assert response.status_code == 200
        print(response.url)
        values = {}
        json_response = json.dumps(response.json())
        features_dict = json.loads(json_response)
        features_number = len(features_dict['features'])
        print(pol + ' - Total des resultats : ' + str(features_number) +' - Filtre sur le code station ' + str(station))     
        for i in range(0, features_number):
            ue = features_dict["features"][i]["properties"]["code_station_ue"]
            if int(ue) == station :
                sample_date = datetime.strptime(features_dict["features"][i]["properties"]["date_debut"],'%Y-%m-%dT%H:%M:%SZ')
                key = datetime.strftime(sample_date,'%y%m%d')
                values[key] = []
                values[key].append(features_dict["features"][i]["properties"])                
        sample_keys = list(values)
        sample_keys.sort()
        sample_keys.reverse()
        last_sample = sample_keys[0]
        result[pol] = []
        result[pol].append(values[last_sample])
        print('--> Taking ' +pol+' sample of day '+sample_keys[0])
    result['atmo'] = take_air_quality_data()
    nox = result["nox"][0][0]["valeur"]
    no2 = result["no2"][0][0]["valeur"]
    o3 = result["o3"][0][0]["valeur"]
    atmo = result["atmo"]["valeur"]    
    return nox, no2, o3, atmo

def take_air_quality_data():
    headers = {'Content-Type': 'application/json'}
    mes_request = 'ind_idf_agglo' 
    params = {'service':'WFS', 'version':'1.0.0', 'request':'GetFeature', 'typeName':mes_request, 'outputFormat':'application/json'}
    response = requests.get(airparif_url, params=params, headers=headers)
    assert response.status_code == 200
    print(response.url)
    json_response = json.dumps(response.json())
    features_dict = json.loads(json_response)
    values = features_dict["features"][0]["properties"]
    return values

def define_brightness():
    return 100

def take_picture(TLname):
    arg = ''
    if TLname == 'hardware_sample':
        arg = ' --rotate 180'
    brightness = str(define_brightness())
    pic = pic_folder+"timelapse/inPic/EdenPic_"+TLname+"_the"+timeNow()+".jpg"
    os.system("fswebcam -r 640x480 -b"+arg+" --no-banner --set gamma=150 --set brightness="+brightness+" --set sharpness=5 --set contrast=15 "+pic)
    print('Taking picture ' + pic)
    return pic

def take_hygromethermography():
    sensor = Adafruit_DHT.DHT11
    print('---> Hygrometermography on pin '+str(hygro_pin))
        # Try to grab a sensor reading.  Use the read_retry method which will retry up
        # to 15 times to get a sensor reading (waiting 2 seconds between each retry).
    humidity, temperature = Adafruit_DHT.read_retry(sensor, hygro_pin)
    if humidity is not None and temperature is not None:
        print('Temp={0:0.1f}*C  Humidity={1:0.1f}%'.format(temperature, humidity))
    else:
        print('Failed to get reading. Try again!')
    return float(temperature), float(humidity)    

def take_cputemp():
    #Gives CPU temperature
    cmd = '/opt/vc/bin/vcgencmd measure_temp'
    line = os.popen(cmd).readline().strip()
    temperature = line.split('=')[1].split("'")[0]
    return temperature

def set_servo(tilt, pan):
    print('Servo 4 to '+ str(tilt))
    pwm.set_pwm(4, 0, tilt)
    print('Servo 5 to '+ str(pan))
    pwm.set_pwm(5, 0, pan)


# Define the parametric_timelapse class 
class ParametricTimelapse:
    # Enter the number of days, and the name of timelapse
    # Shot dict tilt_In, tilt_Out, pan_In, pan_Out, process
    # process : 0=no, 1=horizontal mirror, 2=vertical mirror, 3=horizontal+vertical 

    shot = {1250, 1250, 1350, 1350, 2}
    shots = {'diagonal1':[590, 680, 175, 625, 0],
    'zenithal1':[1100, 1300, 1300, 1300, 0],
    'zenithal2':[500, 680, 400, 400, 0],
    'zenithal3':[1100, 1500, 1300, 1300, 2],
    'circle1':[420, 420, 310, 490, 2],
    'circle2':[1300, 1400, 1050, 1650, 2],
    'frontstill1':[1330, 1330, 1330, 1330, 2],
    'frontstill2':[1200, 1200, 1300, 1300, 2],
    'hardware_sample':[2000, 2000, 1350, 1350, 2]
    }

    def __init__(self, duration, name):
        #self.pwm = Adafruit_PCA9685.PCA9685()
        header()
        print('Initialisation of a ' + name)    
        self.wait_time = round((duration*86400)/total_frames)
        for s in self.shots.keys():
            if s == name:
                shot = self.shots[s]
        self.tilt_in = shot[0]
        self.tilt_out = shot[1]
        self.tilt_step = (self.tilt_out - self.tilt_in)/total_frames
        self.pan_in =  shot[2]
        self.pan_out = shot[3]
        self.pan_step = (self.pan_out - self.pan_in)/total_frames
        self.process = shot[4]
        self.TLname = name + "_" + strftime("%-y%m%d_%H%M%S", time.localtime())

    def parametric_timelapse(self):
        print('Starting parametric timelapse')    
        for i in range(1, total_frames, 1):
            pos_tilt = round(self.tilt_in+self.tilt_step*i)
            pwm.set_pwm(4, 0, pos_tilt)
            pos_pan = round(self.pan_in+self.pan_step*i)
            pwm.set_pwm(5, 0, pos_pan)
            print('-> Pic '+str(i)+'/'+str(total_frames)+' - Servo 4 to '+ str(pos_tilt) + ' & Servo 5 to '+ str(pos_pan))
            time.sleep(1)   
            take_picture(self.TLname)
            print('---> Will wait for ' + str(self.wait_time) +' seconds')
            time.sleep(self.wait_time)            

    def make_gif(self):        
        #create a gif and write on older file if there are more than one       
        print('-------> Making Gif')
        arg = ''
        if self.process == 2 :
            arg = '--flip-vertical '
        raw = pic_folder+'timelapse/outGif/EdenRaw_'+self.TLname+'.gif'
        self.output_gif = pic_folder+'timelapse/outGif/Eden_'+self.TLname+'.gif'
        os.system('convert -delay '+bifrost.delay+' -loop 0 '+pic_folder+'timelapse/inPic/EdenPic_'+self.TLname+'*.jpg '+raw)
        os.system('gifsicle -O3 -f -V -i --colors '+bifrost.colors+' --color-method blend-diversity '+ arg +raw+' -o '+self.output_gif)
        os.remove(raw)
        if os.path.exists(self.output_gif):
            clean_pic(self.TLname)
        else:
            print('-----> No output GIF, source pic not deleted')

    def run(self):
        #create_TLfiles(self.TLname)
        self.parametric_timelapse()
        self.make_gif()
        return self.output_gif


# Define a generic data_sample classe
class DataSample:
    # Data order: cpu_temp, gh_temp, humidity, nox, no2, o3, atmo, date
    # Sample type : 1 = hardware / 2 = open data / 3 = open + hard / 4 =partial
    def __init__(self, sample_type):
        header()
        self.status = int("40" + str(sample_type))
        if (sample_type == 1) or (sample_type == 3) : 
            self.cpu_temp = float(take_cputemp())
            self.gh_temp, self.humidity = take_hygromethermography()
        if (sample_type == 2) or (sample_type == 3) : 
            self.nox, self.no2, self.o3, self.atmo = take_air_data()
        self.sample_date = datetime.now()

    def print_data(self):
        print(self)
 

# Define the parametric_timelapse class 
class Timelapse:
    # Enter the number of days, and the name of timelapse
    # Shot dict tilt_In, tilt_Out, pan_In, pan_Out, process
    # process : 0=no, 1=horizontal mirror, 2=vertical mirror, 3=horizontal+vertical 



    def __init__(self, duration, name=None):
        #self.pwm = Adafruit_PCA9685.PCA9685()
        header()
        self.name = name
        shot_selected = {}
        if name == None:
            shots = skutr.return_db_tl()
            shot_selected = bifrost.present_dict(shots)
        else:
            shot_selected = skutr.return_tl_from_search(name)
        self.name = shot_selected[0]
        shot = shot_selected[1]
        self.TLname = self.name + "_" + strftime("%-y%m%d_%H%M%S", time.localtime())
        print('Initialisation of ' + self.TLname)
        self.duration = duration
        self.length = total_frames        
        self.wait_time = round((duration*86400)/total_frames)
        self.tilt_in = shot[0]
        self.tilt_out = shot[1]
        self.tilt_step = (self.tilt_out - self.tilt_in)/total_frames
        self.pan_in =  shot[2]
        self.pan_out = shot[3]
        self.pan_step = (self.pan_out - self.pan_in)/total_frames
        self.process = int(str(shot[4])[2])
        self.status = int(shot[4])
        self.shot_id = int(shot[5])
        print('----> Saving ' + self.TLname +' in database')
        self.VSId = skutr.insert_timelapse(self)        

    def parametric_timelapse(self):
        print('Starting parametric timelapse')    
        for i in range(1, total_frames+1, 1):
            pos_tilt = round(self.tilt_in+self.tilt_step*i)
            pwm.set_pwm(4, 0, pos_tilt)
            pos_pan = round(self.pan_in+self.pan_step*i)
            pwm.set_pwm(5, 0, pos_pan)
            print('---> Pic '+str(i)+'/'+str(total_frames)+' - Servo 4 to '+ str(pos_tilt) + ' & Servo 5 to '+ str(pos_pan))
            time.sleep(1)   
            self.output_pic = take_picture(self.TLname)
            skutr.save_timeline_progress(self, i)
            print('-> Will wait for ' + str(self.wait_time) +' seconds')
            time.sleep(self.wait_time)            

    def make_gif(self):        
        #create a gif and write on older file if there are more than one       
        print('------> Making Gif')
        arg = ''
        if self.process == 2 :
            arg = '--flip-vertical '
        raw = pic_folder+'timelapse/outGif/EdenRaw_'+self.TLname+'.gif'
        self.output_gif = pic_folder+'timelapse/outGif/Eden_'+self.TLname+'.gif'
        os.system('convert -delay '+bifrost.delay+' -loop 0 '+pic_folder+'timelapse/inPic/EdenPic_'+self.TLname+'*.jpg '+raw)
        os.system('gifsicle -O3 -f -V -i --colors '+bifrost.colors+' --color-method blend-diversity '+ arg +raw+' -o '+self.output_gif)
        os.remove(raw)
        if os.path.exists(self.output_gif):
            clean_pic(self.TLname)
        else:
            print('-----> No output GIF, source pic not deleted')

    def run(self):
        #create_TLfiles(self.TLname)
        self.parametric_timelapse()
        if self.length > 1 :
            self.make_gif()
            return self.output_gif
        else :
            return self.output_pic

