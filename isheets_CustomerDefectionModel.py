# Importing data from Postgres into Python

import psycopg2
import pandas as pd
import numpy as np
from sklearn import metrics 
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

database = {
            'user' : 'postgres',
            'pass' : '100Million',
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

x = result.drop('churn',axis = 1)
y = result.churn

x_train, x_test, y_train, y_test = train_test_split(x, y, random_state=4)

logistic_regression = LogisticRegression(max_iter = 10000)

logistic_regression.fit(x_train,y_train)

y_pred = logistic_regression.predict(x_test)

accuracy = metrics.accuracy_score(y_test, y_pred)
accuracy_percentage = 100 * accuracy
accuracy_percentage