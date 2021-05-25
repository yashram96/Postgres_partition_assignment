import psycopg2
import json
import csv
import pandas as pd
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.types import String
import requests

# Take input as constraints from date ,to date,keywords,no of records need
from_ym=input("\nEnter the from date(YYYY-MM):")#'2012-04'
to_ym=input("\nEnter the to date(YYYY-MM):")#'2020-05'
key_words=input("\n Enter the keywords:")#'mobile camera'
no_of_data=input("\nEnter the no of records:")

#list the month and year
x = from_ym.split("-")
y = to_ym.split("-") 
print(x,y)
count = 0

start_year=int(x[0])
start_month=int(x[1])
end_month=int(y[1])
end_year=int(y[0])
#calculate total number of months from date to to_date
ym_start= 12*start_year + start_month - 1
ym_end= 12*end_year + end_month+1


k=0
temp={}
# loop will call the patent_search function every month ,so that api will hit host every month within range giving
for i in range(ym_start,ym_end):
    y,m=divmod(i,12)
    mon=m+1
    to_date=str(y)+'-'+str(mon)+'-01'
    temp[k]=to_date
    if k>=1 :
        from_date=temp[k-1]
        
        patent_search(from_date,to_date,key_words,no_of_data)
    k=k+1

    
    
#example: patent_search('2020-01-01','2021-05-01','mobile camera',1000)
#This function forms the api with fields that are requested and call another function to extract_data
def patent_search(more_date,less_date,test,no_of_results):
    no_of_results=str(no_of_results)
    url="https://api.patentsview.org/patents/query?"
    form="&f=[%22patent_number%22,%22patent_date%22,%22patent_title%22]"
    greater="&q={%22_and%22:%20[{%22_gte%22:{%22patent_date%22:%22"
    lessthan="%22}},{%22_lte%22:{%22patent_date%22:%22"
    find_text="%22}},{%22_text_any%22:{%22patent_abstract%22:%22"
    endlog="%22}}]}"
    pag_nat="&o={%22page%22:2,%22per_page%22:"+no_of_results+"}"
    space_rep=test.replace(" ",'%20')
    # final form of api
    final_url=url+form+greater+more_date+lessthan+less_date+find_text+space_rep+endlog+pag_nat
    extract_data(final_url)
# Function hits the host and extract the json data 
def extract_data(url_link):
    j_data = requests.get(url_link)
    y = j_data.json()
    # function writes json data to csv
    write_to_csv(y)

# function write json data extracted to csv file
def write_to_csv(json_data):
    data_file = open('patents_data_file.csv', 'w+')
    data_file.close()
    patents_data = json_data['patents']
    data_file = open('patents_data_file.csv', 'a+')
    csv_writer = csv.writer(data_file)
    global count # count to know the header is present in csv
    
    
    for p in patents_data:
        if count == 0:
            header = p.keys()
            csv_writer.writerow(header)   # first  row as header and increment header
            count += 1
            file_hits=1
        
        csv_writer.writerow(p.values())
    
    data_file.close()   


#postgres database details
dbname="sample_test" 
user="postgres" 
password="goodlife"
db_host="localhost"

#Establish the connecction with database
conn=psycopg2.connect(dbname=dbname,user=user,password=password,host=db_host)
cur=conn.cursor()



# create parent table (patents_data)
cur.execute("CREATE TABLE patents_data(patent_number VARCHAR ,patent_date DATE, patent_title VARCHAR)")
conn.commit()
cur.close()

conn=psycopg2.connect(dbname=dbname,user=user,password=password,host=db_host)
cur=conn.cursor()
#insert the csv file data to database (parent_data table)
with open('patents_data_file.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader) # Skip the header row.
    for row in reader:
        cur.execute("INSERT INTO patents_data VALUES (%s, %s, %s)",row )
    conn.commit()
    f.close()
    print("\nInserted succesfully")
    cur.close()
    conn.close()
    