# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 Nov | 6135.88                        | (5822.62, 6449.14)      |
| 2023 Dec | 7969.77                        | (7532.40, 8407.14)      |
| 2024 Jan | 5052.15                        | (4750.70, 5353.60)      |
| 2024 Feb | 5106.73                        | (4773.26, 5440.20)      |
| 2024 Mar | 5702.65                        | (5294.13, 6111.17)      |
| 2024 Apr | 5632.92                        | (5190.45, 6075.39)      |
| 2024 May | 6151.09                        | (5622.55, 6679.63)      |
| 2024 Jun | 6089.12                        | (5518.76, 6659.49)      |
| 2024 Jul | 6304.36                        | (5663.21, 6945.51)      |
| 2024 Aug | 6069.07                        | (5401.75, 6736.40)      |
| 2024 Sep | 5764.28                        | (5081.89, 6446.66)      |
| 2024 Oct | 5916.23                        | (5165.24, 6667.22)      |

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
| ets    |                   7 | -52.08224 | 106.7644 | 1.787010 | 123.1006 | -0.2595692 |
| snaive |                   7 | 112.21429 | 115.7143 | 1.912207 | 151.0267 | -0.1227301 |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
