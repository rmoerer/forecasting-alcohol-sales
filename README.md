# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 Apr | 5619.08                        | (5329.69, 5908.46)      |
| 2023 May | 6162.00                        | (5818.86, 6505.13)      |
| 2023 Jun | 6102.52                        | (5734.56, 6470.48)      |
| 2023 Jul | 6341.54                        | (5927.56, 6755.53)      |
| 2023 Aug | 6132.27                        | (5699.38, 6565.15)      |
| 2023 Sep | 5799.17                        | (5357.37, 6240.96)      |
| 2023 Oct | 5959.09                        | (5470.33, 6447.85)      |
| 2023 Nov | 6205.18                        | (5658.69, 6751.68)      |
| 2023 Dec | 8029.96                        | (7272.67, 8787.25)      |
| 2024 Jan | 5111.03                        | (4596.30, 5625.76)      |
| 2024 Feb | 5163.75                        | (4609.92, 5717.58)      |
| 2024 Mar | 5794.12                        | (5134.04, 6454.21)      |

## Data & methodology

### Background

The United States Census Bureau releases a report each month of monthly
estimates of retail sales for a variety of business sectors. One
particular estimate that is released is an estimate of monthly retail
sales for beer, wine, and liquor stores. This data series has
historically displayed a very predictable trend and seasonal pattern,
suggesting that it can be predicted by time series forecasting methods.

### The data

The US retail beer, wine, and liquor stores sales data is given as total
sales in millions of dollars. Only retail sales data going back to 2010
is considered. This cutoff was arbitrarily chosen so that older data
didn’t have an impact on the model estimates.

### Tools

The sales data is pulled from fred.com API using the `fredr` R package.
The `fable` package is then used to fit the time series models and
generate forecasts. The sales data and forecasts for sales are stored in
an SQLite database\*.

\**Note*: The US Census Bureau will revise it’s estimates for previous
months as new releases become available. The way I’ve decided to handle
this is to update the observations themselves for the revised estimates
when computing forecasting evaluations. However, the forecasts
themselves do not get updated as they are based only on data available
at the time of the forecast.

### Forecasting Workflow

The primary model for forecasting beer, wine, and liquor store sales is
an ETS model on the log transform of sales. This model is automatically
selected each month according to AIC using the automated model selection
algorithm available in the `fable` package. A seasonal naive model
(which is simply the observation from the previous year for a given
month) and an automatically selected ARIMA model are also fit and
considered as benchmarks.

The general forecasting workflow for a given data release can be
summarized in the following steps:

- Retail sales data going back to 2010 is pulled from fred.com.
- The ETS model is re-estimated on the data to account for new
  observations in the data release.
  - The benchmark models are also re-estimated at this step.
- The model and benchmark models are saved and ETS forecasts for the
  next 12 months are generated and stored in the SQLite database.
- A plot and summary of the ETS forecasts for the next 12 months are
  generated.
- Forecast accuracy metrics are recomputed to account for the new data.
- The README is re-rendered with the updated plots and accuracy metrics.

## Forecasts evaluation

### Overall accuracy measures for 1 to 12-month ahead forecasts

| Model  | Forecasting Periods |  ME | MAE | MAPE | RMSE | ACF1 |
|:-------|--------------------:|----:|----:|-----:|-----:|-----:|
| arima  |                   0 | NaN | NaN |  NaN |  NaN |   NA |
| ets    |                   0 | NaN | NaN |  NaN |  NaN |   NA |
| snaive |                   0 | NaN | NaN |  NaN |  NaN |   NA |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
