# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2023 Dec | 8028.02                        | (7618.59, 8437.45)      |
| 2024 Jan | 5101.00                        | (4818.20, 5383.79)      |
| 2024 Feb | 5152.81                        | (4841.32, 5464.30)      |
| 2024 Mar | 5783.57                        | (5402.28, 6164.86)      |
| 2024 Apr | 5705.40                        | (5295.89, 6114.91)      |
| 2024 May | 6256.86                        | (5769.34, 6744.38)      |
| 2024 Jun | 6214.05                        | (5690.27, 6737.83)      |
| 2024 Jul | 6431.15                        | (5846.97, 7015.33)      |
| 2024 Aug | 6205.63                        | (5600.50, 6810.76)      |
| 2024 Sep | 5887.42                        | (5273.43, 6501.40)      |
| 2024 Oct | 6025.17                        | (5355.60, 6694.74)      |
| 2024 Nov | 6280.66                        | (5539.46, 7021.86)      |

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
| ets    |                   8 | -16.15569 | 105.2879 | 1.742279 | 120.7214 | -0.2146479 |
| snaive |                   8 | 121.77778 | 122.1667 | 1.997426 | 150.7682 | -0.2397903 |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
