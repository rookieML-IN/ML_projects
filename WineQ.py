# Loading Libraries

import pandas as pd
import numpy as np
from sklearn import preprocessing
from sklearn.linear_model import LinearRegression
from sklearn.feature_selection import f_regression
import csv
from sklearn import metrics
from sklearn.model_selection import GridSearchCV

# Loading Datasets

data_train = pd.read_csv('E:/ML_CompPract/AIcrowd/WineQ/train.csv',header=None)
data_test = pd.read_csv('E:/ML_CompPract/AIcrowd/WineQ/test.csv',header=None)

''' Dataset Dimensions '''
data_train.shape # 3918,12
data_test.shape # 981,12

# Feature Engineering 

''' Missing Values '''
data_train.isnull().sum() # None
data_test.isnull().sum()  # None

''' Outliers Determination '''
Q1 = data_train.quantile(0.25)
Q3 = data_train.quantile(0.75)
IQR = Q3 - Q1
data_train_out = data_train[~((data_train < (Q1 - 1.5 * IQR)) |(data_train > (Q3 + 1.5 * IQR))).any(axis=1)]
data_train_out.shape   # 3094,12. # 824 rows were removed as outliers

Q1 = data_test.quantile(0.25)
Q3 = data_test.quantile(0.75)
IQR = Q3 - Q1
data_test_out = data_test[~((data_train < (Q1 - 1.5 * IQR)) |(data_test > (Q3 + 1.5 * IQR))).any(axis=1)]
data_test_out.shape   # 788,12. # 193 rows were removed as outliers

''' Rescaling '''
data_train_out.columns = ['fixed acidity','volatile acidity','citric acid','residual sugar','chlorides','free sulfur dioxide','total sulfur dioxide','density','pH','sulphates','alcohol','quality']
feature_names = ['fixed acidity','volatile acidity','citric acid','residual sugar','chlorides','free sulfur dioxide','total sulfur dioxide','density','pH','sulphates','alcohol']
feature_train = data_train_out[feature_names]
scaler = preprocessing.StandardScaler()
s_data_train_out = scaler.fit_transform(feature_train)
X_train = pd.DataFrame(s_data_train_out)
y_train = data_train_out['quality']

feature_train = data_test_out
scaler = preprocessing.StandardScaler()
s_data_test_out = scaler.fit_transform(feature_train)
X_test = pd.DataFrame(s_data_test_out)

# Model

''' Training '''
linreg = LinearRegression()
linreg.fit(X_train,y_train)
y_train_pred = abs(linreg.predict(X_train))
fregression=f_regression(X_train, y_train)

''' Model Evaluation '''
print("RMSE=", np.sqrt(metrics.mean_squared_error(y_train, y_train_pred)))
print("Rsquare=",metrics.r2_score(y_train, y_train_pred))

''' Testing '''
linreg = LinearRegression()
linreg.fit(X_train,y_train)
y_test_pred = np.round(abs(linreg.predict(X_test)))

# Exporting
output = pd.DataFrame(y_test_pred)
output.columns = ['quality']
output.to_csv('C:/Users/ASHUTOSH DAS/Desktop/submission.csv',header=True,index=False)
