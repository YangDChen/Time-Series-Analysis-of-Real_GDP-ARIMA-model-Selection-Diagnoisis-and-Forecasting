# 實質 GDP 的時間序列分析：ARIMA 模型選擇與預測（Time Series Analysis of Real GDP: ARIMA Model Selection and Forecasting）

## 研究簡介（Project Overview）
在此研究中，我使用時間序列分析方法，針對美國實質 GDP（Real GDP）進行ARIMA/ARMA模型建立、樣本外預測與殘差分析。（This project conducts a time-series analysis of U.S. Real GDP using ARIMA/ARMA models, including out-of-sample forecasting and residual diagnostics.）

	- 研究資料：資料取自FRED(代號 = GDPC1)，季資料，1947Q1–2024Q2。（Data: FRED(Code = GDPC1), quarterly, 1947 Q1 – 2024 Q2.）
	
	- 核心模型：根據BIC資訊評選準則，選擇較精簡的 ARMA(1,0)。（Core model: ARMA(1,0) selected by BIC.）
	
	- 評估方式：將訓練集/驗證集作切分，使用 MAE、RMSE。（Evaluation: train/validation split with MAE and RMSE.）
	
	- 殘差分析：Ljung–Box test、Jarque–Bera test、White test。（Diagnostics: Ljung–Box test, Jarque–Bera test, and White tests.）


---


## 重點摘要（Quick start!）
- 文章全文（Full report）：[`report/實質GDP的時間序列分析_ARIMA模型選擇與預測.pdf`](report/實質GDP的時間序列分析_ARIMA模型選擇與預測.pdf)
- 主要程式碼（Main R script）：[`code/TimeSeries_RealGDP.R`](code/TimeSeries_RealGDP.R)

---

## 專案內容（Repository Contents）
- `report/實質GDP的時間序列分析_ARIMA模型選擇與預測.pdf`（完整研究報告 / Full report）
- `code/TimeSeries_RealGDP.R`（資料處理、模型選擇、預測、診斷 / Data processing, model selection, forecasting, diagnostics）
- `data/`（原始資料 / Raw data）
- `figures/`（圖表 / Figures）

---

## 摘要（Abstract）
	本研究採用時間序列分析方法，針對美國實質國內生產毛額(Real Gross Domestic Product, Real GDP)進行實證研究與預測分析。研究資料取自美國聯邦儲備系統經濟資料庫(Federal Reserve Economic Data, FRED)，樣本期間為1947年第一季至2024年第二季，資料頻率為季資料。考量實質GDP之原始資料具有明顯趨勢與非定態特性，本研究透過取自然對數轉換與一階差分方式，將原始資料轉換為定態時間序列，並使用Augmented Dickey-Fuller (ADF)檢定，確認其定態性。
	在模型建構方面，本研究採用自我迴歸整合移動平均模型(ARIMA)，並結合自相關函數(ACF)、偏自相關函數(PACF)、赤池與貝氏資訊評選準則(Akaike Information Criterion, AIC；Bayesian Information Criterion, BIC)進行模型期數(Order)選擇。實證結果顯示，在大樣本情況下，依據BIC準則，會選取之較精簡模型：ARMA(1,0)。接下來，本研究進一步將樣本劃分為訓練集與驗證集，以樣本外預測作為模型效能評估依據，並以平均絕對誤差(MAE)與均方根誤差(RMSE)衡量預測準確度。
	殘差分析結果顯示，模型殘差不具顯著序列相關性，顯示ARMA(1,0)能有效捕捉實質GDP成長率之主要動態結構，並且符合同質性假設，但不服從常態分配，呈現厚尾(Heavy tailed)特性。
	實證結果顯示，ARMA(1,0)模型在經過訓練集擬合後，於驗證集中之預測表現有所提升，且模型之一階自我迴歸係數在統計上顯著。不過，由於模型僅考慮了一階自我迴歸項與常數項，對於波動較為劇烈之時間序列資料，其適用性可能受限，因此，未來仍有進一步改良與延伸模型之研究空間。

---

## 研究方法概覽（Methodology Overview）

### 資料來源（Data Source）

- FRED：GDPC1（Real Gross Domestic Product）
- 資料頻率與期間：季資料，1947Q1–2024Q2（Quarterly, 1947 Q1 – 2024 Q2）

### 模型建構流程（Workflow）

1. 資料視覺化與初步檢視（Visualization & EDA）
   
2. 取自然對數並一階差分，使序列趨近定態（Log transform & first differencing）
   
3. ADF 定態性檢定（ADF stationarity test）
   
4. ACF/PACF 輔助判斷期數（ACF/PACF inspection）
   
5. 以 AIC/BIC 進行模型比較（Model selection via AIC/BIC）
    
6. 使用 `auto.arima()` 交叉驗證模型期數（Cross-check with `auto.arima()`）
    
7. 訓練集/驗證集切分，做樣本外預測（Train/validation split and out-of-sample forecasting）
    
8. 殘差診斷與檢定（Residual diagnostics: Ljung–Box, Jarque–Bera, White test）
    
9. 以 MAE / RMSE 評估預測誤差（Forecast evaluation using MAE/RMSE）

---

## 主要結果（Main Results）

### 模型選擇（Model Selection）

- 根據資訊評選準則，即AIC與BIC，前者偏好較複雜的模型；而在大樣本下，後者則偏好較精簡的模型，我最終選擇ARMA(1,0)作為主要模型。（AIC tends to favor more complex models; BIC prefers parsimonious models in large samples—final choice: ARMA(1,0).）
  
- 根據`auto.arima()` ，也得到ARMA(1,0)模型之結果。（`auto.arima()` also selects ARMA(1,0).）

### 樣本切分（Train/Validation Split）

- 訓練集：1947-01-01 至 2022-10-01。（Train: 1947-01-01 to 2022-10-01.）
  
- 驗證集：2023-01-01 至 2024-07-01。（Validation: 2023-01-01 to 2024-07-01.）

### 預測表現（Forecast Performance）

| 指標（Metric） | 訓練集（Train） | 驗證集（Validation） |
|---|---:|---:|
| MAE（Mean Absolute Error） | 0.0070 | 0.0015 |
| RMSE（Root Mean Squared Error） | 0.0112 | 0.0019 |

### 殘差分析（Residual Diagnostics）

- Ljung–Box：未發現顯著序列相關（No serial correlation detected）。
  
- Jarque–Bera：殘差不服從常態，具厚尾特性（Residuals are non-normal with heavy tails）。
  
- White / 同質性檢定：在 5% 顯著水準下不拒絕同質性（Fail to reject homoskedasticity at 5% level）。

---

## 如何重現結果（Reproducibility）

1. 安裝套件（Install packages）：`forecast`, `tseries`, `lmtest`, `ggplot2`, `dplyr`, `psych`, `knitr`, `kableExtra`
   
2. 下載資料（Download data）：
   - 將 `usa_realgdp.csv` 放在 `data/raw/`（或改用資料下載腳本）
   - 並在 R code 中改用相對路徑（use relative paths）

3. 執行程式（Run the script）：
   - `code/TimeSeries_RealGDP.R`

---

## 未來延伸方向（Future Work）
- 季節性模型：SARIMA（Seasonality-aware SARIMA）
  
- 加入外生變數：ARIMAX / Dynamic Regression（ARIMAX / dynamic regression with macro factors）

---
  
- 機器學習方法：例如 LASSO（Machine learning approaches such as LASSO）

## 引用方式（Citation）

若欲使用本專案內容，歡迎引用此repo或PDF檔案。（If you use this repository, please cite the repo or the PDF report.）
