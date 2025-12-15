import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.tsa.arima.model import ARIMA

file_path = "/Users/yangchen/R_files/Thesis/RealGDP_Data/usa_realgdp.csv"
data = pd.read_csv(file_path)

print(data.head())

data["Date"] = pd.to_datetime(data["Date"])

data["log_real_GDP"] = np.log(data["Real_GDP"]).diff()
log_data = data.dropna(subset = ["log_real_GDP"]).copy()

log_data["year"] = log_data["Date"].dt.year
train_data = log_data[log_data["year"] <= 2022].reset_index(drop = True)  #訓練集
validation_data = log_data[log_data["year"] > 2022].reset_index(drop = True)  #驗證集

train_data.set_index("Date", inplace=True)

model = ARIMA(train_data["log_real_GDP"], order = (1, 0, 0)).fit()

print(model.summary())
