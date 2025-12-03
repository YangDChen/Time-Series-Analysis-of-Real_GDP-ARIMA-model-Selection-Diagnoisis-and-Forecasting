# Time Series Analysis of U.S.A. Real GDP (1947–2024)

  This repository contains an empirical time-series analysis of U.S. Real Gross Domestic Product (Real GDP) using ARIMA models.
  
  The project includes:
  
  TimesSeries_RealGDP.pdf – Full research report
  
  TimeSeries_realGDP.R (from PDF) – R code for data processing, modeling, and diagnostics
  
  Raw Data – Real GDP quarterly data retrieved from FRED
  
  This study demonstrates a complete workflow for univariate time-series modeling, including stationarity testing, ARIMA model selection, forecasting, and residual diagnostics.

## 1. Research Objective

Real GDP is one of the most essential macroeconomic indicators for understanding economic growth, business cycles, and policy impact.
The objective of this project is:

To build an ARIMA model for U.S. Real GDP (quarterly data from 1947–2024) and evaluate its forecasting performance.

## 2. Methodology Overview

(1) Data Source

	(a) Federal Reserve Economic Data (FRED)
	
	(b) Series: GDPC1 (Real Gross Domestic Product)
	
	(c) Frequency: Quarterly, 1947Q1–2024Q2

(2) Methodological Steps

  (a) Exploratory Data Analysis (EDA)

  (b) Log transformation & differencing

  (c) ADF test for stationarity

  (d) ACF/PACF visual inspection

  (e) Model selection using AIC / BIC
  
  (f) auto.arima() model search

  (g) Training / Validation split

  (h) Forecasting with ARMA(1,0)

  (i) Residual diagnostics

   (i) Ljung–Box test

   (ii) Jarque–Bera test

   (iii) Heteroskedasticity test (White test)

   (iv) Q-Q plot

  (j) Performance evaluation

   (i) MAE

   (ii) RMSE

## 3. Main Results

(1) Stationarity

  (a) Original GDP is non-stationary (ADF p = 0.98)

  (b) log-difference is stationary (ADF p < 0.01)

(2) Model Selection

  (a) BIC indicates ARMA(1,0) is the best model

  (b) AIC selects ARMA(2,2), but BIC is preferred in large samples (T > 300)
  
(3) Forecasting Performance (Validation Set)

  | Metric | Train  | Validation |
  | ------ | ------ | ---------- |
  | MAE    | 0.0070 | 0.0015     |
  | RMSE   | 0.0112 | 0.0019     |

(4) Residual Diagnostics

  (a) No serial correlation (Ljung-Box p = 0.86)

  (b) Residuals non-normal (JB p ≈ 0)
 
  (c) Residuals homoskedastic (White test p = 0.09)
 
## 4. Expected Future Work

  (1) SARIMA — captures quarterly seasonality

  (2) ARIMAX / Dynamic Regression — incorporate macro factors

Thank you!
