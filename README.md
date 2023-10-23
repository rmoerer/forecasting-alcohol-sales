# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 Sep | 5710.63                        | (5419.59, 6001.67)      |
| 2023 Oct | 5848.87                        | (5524.67, 6173.07)      |
| 2023 Nov | 6079.71                        | (5712.88, 6446.53)      |
| 2023 Dec | 7884.54                        | (7367.16, 8401.93)      |
| 2024 Jan | 5000.29                        | (4644.13, 5356.46)      |
| 2024 Feb | 5042.87                        | (4653.99, 5431.74)      |
| 2024 Mar | 5642.10                        | (5172.47, 6111.73)      |
| 2024 Apr | 5577.12                        | (5077.62, 6076.61)      |
| 2024 May | 6101.96                        | (5515.80, 6688.12)      |
| 2024 Jun | 6040.35                        | (5419.95, 6660.75)      |
| 2024 Jul | 6253.91                        | (5569.19, 6938.62)      |
| 2024 Aug | 6032.31                        | (5330.32, 6734.30)      |

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
month) and is also fit and considered as a benchmark.

The general forecasting workflow for a given data release can be
summarized in the following steps:

- Retail sales data going back to 2010 is pulled from fred.com.
- The ETS model is re-estimated on the data to account for new
  observations in the data release.
  - The benchmark seasonal naive model is also re-estimated at this
    step.
- The model and benchmark models are saved and ETS forecasts for the
  next 12 months are generated and stored in the SQLite database.
- A plot and summary of the ETS forecasts for the next 12 months are
  generated.
- Forecast accuracy metrics are recomputed to account for the new data.
- The README is re-rendered with the updated plots and accuracy metrics.

## Forecasts evaluation

### Overall accuracy measures for 1 to 12-month ahead forecasts

| Model  | Forecasting Periods |        ME |      MAE |     MAPE |     RMSE |       ACF1 |
|:-------|--------------------:|----------:|---------:|---------:|---------:|-----------:|
| ets    |                   5 | -89.19161 | 111.9856 | 1.848090 | 132.6795 |  0.4050408 |
| snaive |                   5 | 146.13333 | 146.1333 | 2.383771 | 176.9539 | -0.0046100 |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
