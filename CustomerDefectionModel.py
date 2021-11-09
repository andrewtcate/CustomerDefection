# Importing data from Postgres into Python

import psycopg2
import pandas as pd

database = {
            'user' : 'postgres',
            'pass' : 'your password here',
            'name' : 'postgres',
            'host' : 'localhost',
            'port' : '5432'}

pgConnectString = f"""host={database['host']}
                      port={database['port']}
                      dbname={database['name']}
                      user={database['user']}
                      password={database['pass']}"""
                      

pgConnection=psycopg2.connect(pgConnectString)
query = "select * from modelTbl;"
result = pd.read_sql_query(query, pgConnection)
pgConnection.close()
print(result)