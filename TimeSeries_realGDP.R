library(readr)
library(ggplot2)
library(psych)
library(knitr)
library(kableExtra)
library(magrittr)
library(dplyr)
library(lmtest)
library(tseries)
library(forecast)
#library(FinTS) #ArchTest()
#library(sandwich) #Newey-West 標準誤
#library(EnvStats)
#library(moments)
#library(psych) #要拿describe()算敘述統計量(可略過不用，用summary()就好)

r.File <- "/Users/yangchen/R_files/Thesis/RealGDP_Data/usa_realgdp.csv"
data <- read_csv(r.File, col_names = TRUE)

breaks_realgdp <- seq.Date(from = as.Date("1954-01-01"), 
                               to = as.Date("2024-07-01"), 
                               by = "10 years")

ggplot(data, aes(x = Date, y = Real_GDP)) +
  geom_line(color = "blue", linewidth = 0.7) +
  labs(title = "Time Series of real GDP Growth Rate (1947-2024)",
       x = "Date",
       y = "real GDP") +
  scale_x_date(breaks = breaks_realgdp,
               labels = format(breaks_realgdp, "%Y-%m-%d")
               ) +
  theme_bw()

real.gdp <- data$Real_GDP
log_real_gdp <- diff(log(real.gdp))

log_data <- tibble(Date = data$Date[-1],
                   log_real_GDP = log_real_gdp
                   )

breaks_log_realgdp <- seq.Date(from = as.Date("1954-01-01"), 
                       to = as.Date("2024-07-01"), 
                       by = "10 years")

ggplot(log_data, aes(x = Date, y = log_real_GDP)) +
  geom_line(color = "blue", linewidth = 0.7) +
  labs(title = "Time Series of Logarithmic real GDP Growth Rate (1947-2024)",
       x = "Date",
       y = "Logarithmic real GDP") +
  scale_x_date(breaks = breaks_log_realgdp,
               labels = format(breaks_log_realgdp, "%Y-%m-%d")
               ) +
  theme_bw()

sumstats <- function(data) {
  data.frame(
    Statistic = c("Mean", "Standard Deviation", "Skewness", "Kurtosis"),
    Value = c(
      mean(data, na.rm = TRUE),
      sd(data, na.rm = TRUE),
      skew(data, na.rm = TRUE),
      kurtosi(data, na.rm = TRUE)
    )
  )
}

real_gdp_stats <- sumstats(real.gdp)
log_real_gdp_stats <- sumstats(log_real_gdp)

#分開呈現不同資料敘述統計量的表格
cat("Statistics for real.gdp:\n")
kable(real_gdp_stats, caption = "Summary Statistics of real.gdp (Raw Data)")
cat("\nStatistics for log_real_gdp:\n")
kable(log_real_gdp_stats, caption = "Summary Statistics of log_real_gdp (Processed Data)")

##上下合併在一起呈現
#rbind() = row bind 照row的方向合併
combined_stats <- rbind(real_gdp_stats, log_real_gdp_stats)

#左右合併
#data.drame()本質上是靠逐列(column)去建構的，且適合用在建構異質資料框(意即column可以存在不同類型，如character和numeric)；
#相對來說，cbind()需要所有column都是相同類型，否則需要再包一層as.data.frame()來轉換成資料框
combined_stats <- data.frame(Statistic = real_gdp_stats$Statistic,
                             Real_GDP = real_gdp_stats$Value,
                             Log_Real_GDP = log_real_gdp_stats$Value
                             )

kable(combined_stats, caption = "Summary Statistics of Real GDP (Raw Data) and Log Real GDP (Processed Data)")

#kable(combined_stats, caption = "Summary Statistics of Raw Data and Processed Data") %>%
  #kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover", "condensed"))

summary(log_real_gdp)
sd(log_real_gdp)
skew(log_real_gdp)
kurtosi(log_real_gdp)

adf.test(log_real_gdp)

acf <- acf(log_real_gdp)
pacf <- pacf(log_real_gdp)

par(mfrow=c(2,1))
plot(acf, main = "ACF of Logarithmic real GDP")
plot(pacf, main = "PACF of Logarithmic real GDP")

log_data$year <- as.numeric(format(log_data$Date, "%Y"))
train_data <- subset(log_data, year <= 2022)
validation_data <- subset(log_data, year > 2022)

orders <- list(c(1, 0, 0), c(2, 0, 0), c(3, 0, 0), c(1, 0, 1), c(1, 0, 2), 
               c(1, 0, 3), c(2, 0, 1), c(2, 0, 2), c(2, 0, 3)
               )

models <- c()
aic_values <- c()
bic_values <- c()

for (order in orders) {
  mdl <- Arima(train_data$log_real_GDP, order = order)
  
  models <- c(models, paste0("ARMA(", order[1], ",", order[3], ")"))
  aic_values <- c(aic_values, AIC(mdl))
  bic_values <- c(bic_values, BIC(mdl))
  }

results <- data.frame(Models = models, AIC = aic_values, BIC = bic_values)
results

min_aic_model <- results %>%
  filter(AIC == min(AIC)) %>%
  select(Models) %>%
  pull()

min_bic_model <- results %>%
  filter(BIC == min(BIC)) %>%
  select(Models) %>%
  pull()

cat("Model with Minimum AIC:", min_aic_model, "\n")
cat("Model with Minimum BIC:", min_bic_model, "\n")

model <- auto.arima(train_data$log_real_GDP)
model

#或者手動選模型期數
arima_model_10 <- Arima(train_data$log_real_GDP, order = c(1, 0, 0))
arima_model_10

forecasted_values <- forecast(model, h = nrow(validation_data))

#拿模型做完預測值後，計算一下MAE, RMSE, MAPE
#要拿預測值和實際值(測試集資料)，來透過MAE, RMSE, MAPE評估模型的適配程度
accuracy(forecasted_values$mean, validation_data$log_real_GDP)

#手動計算R^2
# actual <- validation_data$log_real_GDP
# predicted <- as.numeric(forecasted_values$mean)
# 
# sst <- sum((actual - mean(actual))^2)  # 總平方和
# sse <- sum((actual - predicted)^2)  # 殘差平方和
# ssr <- sum((predicted - mean(actual))^2) #
# r_squared <- 1 - (sse / sst)
# r_squared

forecasted_data <- log_data %>% 
  mutate(forecasts_real_GDP = ifelse(year > 2022, forecasted_values$mean, NA))

filtered_gdp_all <- forecasted_data %>% 
  filter(Date <= as.Date("2024-07-01"))

breaks_all <- seq.Date(from = as.Date("2022-01-01"), 
                       to = as.Date("2024-07-01"), 
                       by = "3 months")

ggplot(filtered_gdp_all, aes(x = Date)) +
  geom_line(data = filtered_gdp_all %>% filter(year == 2022),
            aes(y = log_real_GDP, color = "Realized GDP Growth Rate (2022)"), 
            linewidth = 1) +
  geom_point(data = filtered_gdp_all %>% filter(year > 2022),
             aes(y = log_real_GDP, color = "Realized GDP Growth Rate (2023-2024)"),
             shape = 16, 
             size = 3) +
  geom_point(data = filtered_gdp_all %>% filter(year > 2022),
             aes(y = forecasts_real_GDP, color = "Forecast GDP Growth Rate (2023-2024)"),
             shape = 4, 
             size = 3) +
  labs(title = "Time Series of Logarithmic real GDP Growth Rate (2022-2024)", 
       x = "Quarters", 
       y = "Logarithmic real GDP Growth Rate") +
  scale_x_date(breaks = breaks_all,
               labels = format(breaks_all, "%Y-%m-%d"),
               limits = c(as.Date("2022-01-01"), as.Date("2024-07-01"))) +
  scale_color_manual(values = c("Realized GDP Growth Rate (2022)" = "cyan4", 
                                "Realized GDP Growth Rate (2023-2024)" = "blue", 
                                "Forecast GDP Growth Rate (2023-2024)" = "red")) +
  guides(color = guide_legend(title = NULL, label.position = "right"), 
         shape = guide_legend(title = NULL, label.position = "right")) +
  theme_bw()

residuals <- residuals(model)

ljung_box_test <- Box.test(residuals, lag = 17, type = "Ljung-Box")
ljung_box_test
summary(model)

jarque.bera.test(residuals)

qqnorm(residuals, pch = 1) 
qqline(residuals, lwd = 2)

lm_residuals <- lm(residuals ~ train_data$log_real_GDP)

bptest(lm_residuals, studentize = FALSE)

coeftest(lm_residuals, vcov. = NeweyWest(lm_residuals))

dates <- seq.Date(from = as.Date("1947-01-01"), 
                  by = "quarter", 
                  length.out = length(residuals))

plot(dates, residuals, type = "l", main = "Time Series of Residuals of ARMA model", 
     ylab = "Residuals", xlab = "Time")

axis(1, at = seq(as.Date("1950-01-01"), as.Date("2020-01-01"), by = "10 years"), 
     labels = seq(1950, 2020, by = 10))

grid()

plot(density(residuals), main = "Residuals Density of ARMA model", xlab = "Residuals", ylab = "Density")
grid()