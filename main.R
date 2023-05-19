# Script to update data and fit/run models, and update README
library(fredr)
library(dplyr)
library(tidyr)
library(tsibble)
library(fable)
library(fabletools)
library(ggplot2)
library(lubridate)
library(distributional)
library(DBI)

source("R/functions.R")

init_year_month <- yearmonth("2010 Jan")
con <- dbConnect(RSQLite::SQLite(), here::here("database", "alcohol_sales.sqlite"))
fredr_set_key(Sys.getenv("FRED_KEY"))
observations <- download_data(init_year_month)

if (dbExistsTable(con, "forecasts")) {
  last_fit_month <- max(yearmonth(dbGetQuery(con, "SELECT fit_year_month FROM forecasts")$fit_year_month))
} else {
  last_fit_month <- NULL
}

if (is.null(last_fit_month) || last_fit_month < max(observations$year_month)) {
  update_observations_table(con, observations)
  
  models <- fit_models(observations)
  saveRDS(models, "models/model_fits.rds")
  forecasts <- make_forecasts(models)
  update_forecasts_table(con, forecasts)
  
  # update README
  rmarkdown::render("README.Rmd", output_file = "README.md")
}

dbDisconnect(con)
