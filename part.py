import psycopg2
import json
import csv
import pandas as pd
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.types import String
import requests


from_ym=input("\nEnter the from date(YYYY-MM):")#'2012-04'
to_ym=input("\nEnter the to date(YYYY-MM):")#'2020-05'
key_words=input("\n Enter the keywords:")#'mobile camera'
no_of_data=input("\nEnter the no of records:")

x = from_ym.split("-")
y = to_ym.split("-") 
print(x,y)
count = 0
start_year=int(x[0])
start_month=int(x[1])
end_month=int(y[1])
end_year=int(y[0])
ym_start= 12*start_year + start_month - 1
ym_end= 12*end_year + end_month+1


k=0
temp={}
for i in range(ym_start,ym_end):
    y,m=divmod(i,12)
    mon=m+1
    to_date=str(y)+'-'+str(mon)+'-01'
    temp[k]=to_date
    if k>=1 :
        from_date=temp[k-1]
        
        patent_search(from_date,to_date,key_words,no_of_data)
    k=k+1

    #print(from_date,to_date)b 
    
#patent_search('2020-01-01','2021-05-01','mobile camera',1000)
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
    final_url=url+form+greater+more_date+lessthan+less_date+find_text+space_rep+endlog+pag_nat
    extract_data(final_url)

def extract_data(url_link):
    #print(url_link)
    j_data = requests.get(url_link)
    #print(response.json())
    y = j_data.json()
    write_to_csv(y)
    #print(y)

def write_to_csv(json_data):
    data_file = open('patents_data_file.csv', 'w+')
    data_file.close()
    patents_data = json_data['patents']
    data_file = open('patents_data_file.csv', 'a+')
    csv_writer = csv.writer(data_file)
    global count
    
    
    for p in patents_data:
        if count == 0:
            header = p.keys()
            csv_writer.writerow(header)
            count += 1
            file_hits=1
        
        csv_writer.writerow(p.values())
    
    data_file.close()   



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
    