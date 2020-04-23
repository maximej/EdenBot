#!/usr/bin/env python3.5
# coding: utf-8

#"Skutr" - The Memory, the back cabin
#This file exchange with the SQLite database
#It handles its reading, writting, updates
#Ensure the integrity of the data

from __future__ import division

# Import generic modules
import os
import sys
import subprocess
import sqlite3
from modules import bifrost
from random import randint


abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
dbname = bifrost.db
database = dname+"/../database/"+dbname

#Prints The Header
def header():
    with open(dname+"/../settings/titre/SkutrTitre.txt",'r') as f:
        header = f.read() 
    print(header)
		
def save_hardware_sample(DS):
	header()
	status = 401
	conn = sqlite3.connect(database)
	data = [getattr(DS, 'cpu_temp'), getattr(DS, 'gh_temp'), getattr(DS, 'humidity'), status]
	c = conn.cursor()
	c.executemany("INSERT INTO DataSample (cpu_t, gh_t, hum, Status, SampleDate) VALUES (?, ?, ?, ?, datetime('now'))", (data,))
	conn.commit()
	conn.close()
	print("---> Database updated with a hardware sample")

def save_data_sample(DS):
	# Data order: cpu_temp, gh_temp, humidity, nox, no2, o3, atmo, date
    # Sample type : 1 = hardware / 2 = open data / 3 = full / 4 =partial
	header()
	status = getattr(DS, 'status')
	table = 'DataSample'
	conn = sqlite3.connect(database)
	data = [getattr(DS, 'cpu_temp'), getattr(DS, 'gh_temp'), getattr(DS, 'humidity'), getattr(DS, 'nox'), getattr(DS, 'no2'), getattr(DS, 'o3'), getattr(DS, 'atmo'), status]
	c = conn.cursor()
	c.executemany("INSERT INTO "+table+" (cpu_t, gh_t, hum, nox, no2, o3, atmo, Status, SampleDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))", (data,))
	conn.commit()
	conn.close()
	print("---> Table "+table+" updated with a "+str(status)+" sample")

def return_db_tl():
	header()
	table = 'Shot'
	print("---> Looking into database for the table "+table)
	conn = sqlite3.connect(database)
	shots_cursor = conn.execute("SELECT SName, TiltIn, TiltOut, PanIn, PanOut, Status, rowid FROM "+ table +" ORDER BY SName ASC;")
	shot = {}
	for row in shots_cursor :
		data = [row[1],row[2],row[3],row[4],row[5],row[6]]
		shot[row[0]]=data
	conn.commit()
	conn.close()
	return(shot)

def return_tl_from_search(name):
	header()
	print("--> Looking into table Shot for "+name)
	conn = sqlite3.connect(database)
	c = conn.cursor()
	name = "%"+name+"%"
	c.execute("SELECT SName, TiltIn, TiltOut, PanIn, PanOut, Status, rowid FROM Shot WHERE SName LIKE ?;", (name,))
	shots_cursor = c.fetchall()
	shot = {}
	results = len(shots_cursor)
	if results == 0:
		print("--> No shot found for "+name)
		shots = return_db_tl()
		shot = bifrost.present_dict(shots)
	if results == 1:
		row = shots_cursor[0]
		data = [row[1],row[2],row[3],row[4],row[5],row[6]]
		shot = [row[0],data]
	if results > 1:
		shots = {}
		for row in shots_cursor :
			data = [row[1],row[2],row[3],row[4],row[5],row[6]]
			shots[row[0]]=data
		shot = bifrost.present_dict(shots)
	conn.commit()
	conn.close()
	return shot
	
def load_famous_tree():
	#self.name, self.N3, self.alias, self.kind, self.plant_name, self.description	
	header()
	print("--> Loading FamousTree table")
	conn = sqlite3.connect(database)
	c = conn.cursor()
	c.execute("SELECT * from FamousTree")
	shots_cursor = c.fetchall()
	tid = randint(1,len(shots_cursor))
	c.execute("SELECT T.FTName, T.N3, T.Alias, T.Kind, P.PName, P.PDescription FROM FamousTree T LEFT JOIN Plant P on T.PlantId = P.rowid WHERE T.rowid = ?;", (tid,))
	shots_cursor = c.fetchall()
	row = shots_cursor[0]
	conn.commit()
	conn.close()
	print(row)
	return row[0],row[1],row[2],row[3],row[4],row[5]

	
def insert_timelapse(TL):
	# Data order: cpu_temp, gh_temp, humidity, nox, no2, o3, atmo, date
    # Sample type : 1 = hardware / 2 = open data / 3 = full / 4 =history
	header()
	table = 'VisualSample'
	status = 201
	conn = sqlite3.connect(database)
	data = [getattr(TL, 'TLname'), getattr(TL, 'shot_id'), 0, getattr(TL, 'length'), getattr(TL, 'duration'), status]
	c = conn.cursor()
	tlid = c.execute("INSERT INTO "+table+" (VSName, DateIn, ShotType, Frame, TotalFrame, Duration, Status) VALUES (?, datetime('now'), ?, ?, ?, ?, ?)", (getattr(TL, 'TLname'), getattr(TL, 'shot_id'), 0, getattr(TL, 'length'), getattr(TL, 'duration'), status,)).lastrowid
	conn.commit()
	conn.close()
	print("---> Table "+table+" updated with rowid ["+str(tlid)+"] : " + str(data))
	return tlid
	
def save_timeline_progress(TL, i):
	table = 'VisualSample'
	conn = sqlite3.connect(database)
	c = conn.cursor()
	c.execute("UPDATE "+table+" SET Frame = ? WHERE rowid = ?", (i, getattr(TL, 'VSId'),))
	conn.commit()
	conn.close()
	print("-> EdenBase updated")

def save_text_archive(status):
	print("TO DO save_text_archive")

def save_text_archive(status):
	print("TO DO save_text_archive")
	
def update_VisualSample_url():
	print("update_VisualSample_url")
