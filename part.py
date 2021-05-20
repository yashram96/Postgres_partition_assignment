import psycopg2
import json
import csv
import pandas as pd
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.types import String
import requests
def patent_search(more_date,less_date,test):
    url="https://api.patentsview.org/patents/query?"
    form="&f=[%22patent_number%22,%22patent_date%22,%22patent_title%22]"
    greater="&q={%22_and%22:%20[{%22_gte%22:{%22patent_date%22:%22"
    lessthan="%22}},{%22_lte%22:{%22patent_date%22:%22"
    find_text="%22}},{%22_text_any%22:{%22patent_abstract%22:%22"
    endlog="%22}}]}"
    space_rep=test.replace(" ",'%20')
    final_url=url+form+greater+more_date+lessthan+less_date+find_text+space_rep+endlog
    extract_data(final_url)

def extract_data(url_link):
    #print(url_link)
    j_data = requests.get(url_link)
    #print(response.json())
    y = j_data.json()
    write_to_csv(y)
    #print(y)

def write_to_csv(json_data):
    patents_data = json_data['patents']
    data_file = open('patents_data_file.csv', 'w+')
    csv_writer = csv.writer(data_file)
    count = 0
    for p in patents_data:
        if count == 0:
            header = p.keys()
            csv_writer.writerow(header)
            count += 1
        csv_writer.writerow(p.values())
    
    data_file.close()   

patent_search('2019-01-01','2021-01-02','mobile camera',100)

dbname="sample_test" 
user="postgres" 
password="goodlife"
db_host="localhost"

conn=psycopg2.connect(dbname=dbname,user=user,password=password,host=db_host)
cur=conn.cursor()


#engine = create_engine('postgresql://postgres:goodlife@localhost:5432/test')

cur.execute("CREATE TABLE patents_data(patent_number VARCHAR ,patent_date DATE, patent_title VARCHAR)")
conn.commit()
cur.close()

conn=psycopg2.connect(dbname=dbname,user=user,password=password,host=db_host)
cur=conn.cursor()
with open('patents_data_file.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader) # Skip the header row.
    for row in reader:
        #df = pd.read_csv("patents_data_file.csv", usecols=col_list)
        #for (k,v) in row.items(): # go over each column name and value 
        #    columns[k].append(v)
        #print(row)
        cur.execute(
        "INSERT INTO patents_data VALUES (%s, %s, %s)",
            #"select sample1(%s,%s,%s)",
            row
        
    )
    conn.commit()
    f.close()
    print("\nInserted succesfully")
    cur.close()
    conn.close()
    