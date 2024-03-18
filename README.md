# Forecasting US beer, wine, and liqour store sales

A repository for automated forecasting of US beer, wine, and liquor
store sales using an ETS model.

## ETS model forecasts for the next 12 months

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" width="100%" />

| Month    | Forecast (millions of dollars) | 95% Prediction Interval |
|:---------|:-------------------------------|:------------------------|
| 2024 Feb | 5107.33                        | (4848.95, 5365.72)      |
| 2024 Mar | 5721.17                        | (5408.52, 6033.81)      |
| 2024 Apr | 5648.96                        | (5313.53, 5984.39)      |
| 2024 May | 6194.95                        | (5794.11, 6595.79)      |
| 2024 Jun | 6127.54                        | (5695.31, 6559.77)      |
| 2024 Jul | 6348.29                        | (5860.71, 6835.88)      |
| 2024 Aug | 6129.58                        | (5618.15, 6641.01)      |
| 2024 Sep | 5812.22                        | (5286.93, 6337.51)      |
| 2024 Oct | 5945.68                        | (5365.52, 6525.84)      |
| 2024 Nov | 6197.49                        | (5546.78, 6848.20)      |
| 2024 Dec | 8028.08                        | (7124.13, 8932.03)      |
| 2025 Jan | 5088.15                        | (4475.76, 5700.54)      |

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

| Model  | Forecasting Periods |        ME |       MAE |     MAPE |     RMSE |       ACF1 |
|:-------|--------------------:|----------:|----------:|---------:|---------:|-----------:|
| ets    |                  10 | -28.00121 |  93.14639 | 1.563155 | 109.2996 | -0.0570708 |
| snaive |                  10 | 100.00000 | 130.80000 | 2.054356 | 154.7637 | -0.3119618 |

## References

U.S. Census Bureau, Retail Sales: Beer, Wine, and Liquor Stores
(MRTSSM4453USN), retrieved from FRED, Federal Reserve Bank of St. Louis;
<https://fred.stlouisfed.org/series/MRTSSM4453USN>, May 18, 2023.
