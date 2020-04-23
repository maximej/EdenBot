import sqlite3

############### Settings ####################
#DB Name
DB_NAME = "EdenBase"

#SQL File with Table Schema and Initialization Data
SQL_File_Name = "EdenBaseCreateInsert.sql"
##############################################

#Read Table Schema into a Variable and remove all New Line Chars
TableSchema=""
with open(SQL_File_Name, 'r') as SchemaFile:
 TableSchema=SchemaFile.read().replace('\n', '')

#Connect or Create DB File
conn = sqlite3.connect(DB_NAME)
curs = conn.cursor()

#Create Tables
sqlite3.complete_statement(TableSchema)
curs.executescript(TableSchema)

#Close DB
curs.close()
conn.close()
