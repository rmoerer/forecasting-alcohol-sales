# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 Jun | 6127.33                        | (5813.60, 6441.06)      |
| 2023 Jul | 6367.62                        | (6015.33, 6719.91)      |
| 2023 Aug | 6159.04                        | (5789.71, 6528.36)      |
| 2023 Sep | 5828.72                        | (5449.53, 6207.90)      |
| 2023 Oct | 5993.38                        | (5570.66, 6416.10)      |
| 2023 Nov | 6233.64                        | (5757.77, 6709.51)      |
| 2023 Dec | 8109.88                        | (7441.39, 8778.38)      |
| 2024 Jan | 5148.88                        | (4691.85, 5605.90)      |
| 2024 Feb | 5195.94                        | (4700.75, 5691.12)      |
| 2024 Mar | 5823.87                        | (5229.73, 6418.01)      |
| 2024 Apr | 5761.01                        | (5133.71, 6388.30)      |
| 2024 May | 6323.49                        | (5590.70, 7056.29)      |

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

| Model  | Forecasting Periods |        ME |       MAE |      MAPE |      RMSE |       ACF1 |
|:-------|--------------------:|----------:|----------:|----------:|----------:|-----------:|
| ets    |                   2 |  39.13861 |  39.13861 | 0.6412974 |  41.83457 | -0.7437749 |
| snaive |                   2 | 260.66667 | 260.66667 | 4.1918825 | 318.43576 | -0.5000000 |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
