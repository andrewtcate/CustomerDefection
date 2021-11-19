# Importing data from Postgres into Python

import psycopg2
import pandas as pd
import numpy as np
from sklearn import metrics 
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import seaborn as sns

#Transferring data from PostgreSQL

database = {
            'user' : 'postgres',
            'pass' : 'book',
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

#Creating Test/Train

x = result.drop('churn',axis = 1)
y = result.churn

x_train, x_test, y_train, y_test = train_test_split(x, y, random_state=4)

logistic_regression = LogisticRegression(max_iter = 10000)

logistic_regression.fit(x_train,y_train)

y_pred = logistic_regression.predict(x_test)

#Confusion Matrix and Accuracy for Predictions

score = logistic_regression.score(x_test, y_test)
print(score)

cm = metrics.confusion_matrix(y_test, y_pred)
print(cm)

plt.figure(figsize=(2,2))
sns.heatmap(cm, annot=True, fmt=".3f", linewidths=.5, square = True, cmap = 'Oranges')
plt.ylabel('Actual Churn')
plt.xlabel('Predicted GLM Churn')
all_sample_title = 'Accuracy Score: {0}'.format(score)
plt.title(all_sample_title, size = 15)
plt.show()

#Determining/Building Naive Predictions

sum(y_test==False)
len(y_test==False)

naive_pred = np.full(
  shape=342,
  fill_value=False,
  dtype=np.bool_
)

#Confusion Matrix for Naive Predictions

cm2 = metrics.confusion_matrix(y_test, naive_pred)
print(cm2)

score2 = logistic_regression.score(x_test, naive_pred)
print(score2)

plt.figure(figsize=(2,2))
sns.heatmap(cm2, annot=True, fmt=".3f", linewidths=.5, square = True, cmap = 'Oranges')
plt.ylabel('Actual Churn')
plt.xlabel('Predicted Naive Churn')
all_sample_title = 'Accuracy Score: {0}'.format(score2)
plt.title(all_sample_title, size = 15)
plt.show()

score #Log Reg Model
score2 #Naive