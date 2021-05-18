import psycopg2
import json
import csv
import pandas as pd
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.types import String

dbname="test" 
user="postgres" 
password="goodlife"
db_host="localhost"



j.data = requests.get("https://api.patentsview.org/patents/query?q={%22_and%22:%20[{%22_gte%22:{%22patent_date%22:%222020-01-01%22}},{%22_lte%22:{%22patent_date%22:%222021-01-02%22}},{%22_text_any%22:{%22patent_abstract%22:%22mobile%20camera%22}}]}&f=[%22patent_number%22,%22patent_date%22,%22patent_title%22]")
print(response.json())

y = json.loads(j_data)

  
patents_data = y['patents']
  

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
  


# conn=psycopg2.connect(dbname=dbname,user=user,password=password,host=db_host)
# cur=conn.cursor()


#engine = create_engine('postgresql://postgres:goodlife@localhost:5432/test')


cur.execute("CREATE TABLE CITATIONS(App_id VARCHAR ,logdate DATE NOT NULL ,PARSED VARCHAR ,IFW_NUMBER VARCHAR ,ACTION_TYPE VARCHAR (20) ,ACTION_SUBTYPE VARCHAR (20) ,FORM892 INT,FORM1449 INT ,CITATION_IN_OA INT )")
conn.commit()

# csv_data = pd.read_csv(r'patents_data_file.csv')
# csv_data.to_sql('patents_data', engine, if_exists='append', index=False, dtype={"patent_number": String(), "patent_date": String(), "patent_title": String()})




if
month="feb"




cur.execute(var)
conn.commit()
col_list = ["patent_date"]

with open('patents_data_file.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader) 
    for row in reader:
    	#df = pd.read_csv("patents_data_file.csv", usecols=col_list)


    	for (k,v) in row.items(): 
            columns[k].append(v)

        cur.execute(
        "INSERT INTO CITATIONS VALUES (%s, %s, %s)",
        row
    )

conn.commit()


with open('patents_data_file.csv', 'r') as csvfile:
    content = csv.reader(csvfile, delimiter=',')
    next(content)
    i=0
    
    for row in content:
        date = int(row[1].split('-')[1])
        year = int(row[1].split('-')[0])
        #print(date)
        #print(year)
        table_name="date_table_{}_{}".format(date,year)
        
        result=checkTableExists(cur,table_name)
        print(table_name)
        




def checkTableExists(dbcon, tablename):
    dbcur = dbcon.cursor()
    dbcur.execute("""
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_name = '{0}'
        """.format(tablename))
    if dbcur.fetchone()[0] == 1:
        dbcur.close()
        return True

    dbcur.close()
    return False