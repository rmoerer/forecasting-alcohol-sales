# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 May | 6182.51                        | (5864.38, 6500.64)      |
| 2023 Jun | 6117.61                        | (5774.30, 6460.92)      |
| 2023 Jul | 6365.83                        | (5973.50, 6758.16)      |
| 2023 Aug | 6152.72                        | (5735.05, 6570.39)      |
| 2023 Sep | 5818.08                        | (5383.07, 6253.09)      |
| 2023 Oct | 5980.71                        | (5489.17, 6472.25)      |
| 2023 Nov | 6218.96                        | (5658.88, 6779.04)      |
| 2023 Dec | 8089.62                        | (7294.29, 8884.96)      |
| 2024 Jan | 5134.56                        | (4585.70, 5683.42)      |
| 2024 Feb | 5183.47                        | (4583.47, 5783.47)      |
| 2024 Mar | 5803.06                        | (5078.56, 6527.56)      |
| 2024 Apr | 5744.08                        | (4973.54, 6514.63)      |

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

| Model  | Forecasting Periods |         ME |       MAE |      MAPE |      RMSE | ACF1 |
|:-------|--------------------:|-----------:|----------:|----------:|----------:|-----:|
| ets    |                   1 |   9.923702 |  9.923702 | 0.1762960 |  9.923702 |   NA |
| snaive |                   1 | -10.000000 | 10.000000 | 0.1776514 | 10.000000 |   NA |
| arima  |                   1 |        NaN |       NaN |       NaN |       NaN |   NA |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
