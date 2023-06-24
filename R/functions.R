
# api functions -----------------------------------------------------------

download_data <- function(start_month) {
  observations <- fredr_series_observations(
    series_id = "MRTSSM4453USN",
    observation_start = as.Date(start_month)
  ) |> 
    mutate(year_month = yearmonth(date)) |> 
    select(year_month, value) |> 
    as_tsibble(index = year_month)
}

# model functions ---------------------------------------------------------

fit_models <- function(data) {
  data |> 
    model(
      ets = ETS(value),
      snaive = SNAIVE(value)
    )
}

make_forecasts <- function(models) {
  model_specs <- models |> 
    as_tibble() |> 
    pivot_longer(everything(), names_to = ".model") |> 
    mutate(.model_spec = format(value)) |> 
    select(.model, .model_spec)
  
  models |> 
    forecast(h = 12) |> 
    left_join(model_specs, by = ".model") |> 
    relocate(.model_spec, .after = .model)
}

# database functions ------------------------------------------------------

# extract all observations from database and return as tsibble
extract_observations <- function(con) {
  observations <- dbGetQuery(con, "SELECT * FROM observations")
  
  observations |> 
    mutate(year_month = yearmonth(year_month)) |> 
    as_tsibble(index = year_month)
}

# extract all forecasts from database and return as tibble
extract_forecasts <- function(con) {
  forecasts <- dbGetQuery(con, "SELECT * FROM forecasts")
  
  forecasts_tsibble <- forecasts |> 
    mutate(
      value = dist_normal(mu = .mean, sigma = sqrt(.var)),
      fit_year_month = yearmonth(fit_year_month),
      year_month = yearmonth(year_month)
    )
}

update_observations_table <- function(con, observations) {
  observations <- observations |>
    as_tibble() |> 
    mutate(year_month = as.character(year_month))
  
  dbWriteTable(con, "observations", observations, overwrite = TRUE)
}

# update forecasts table in database with model forecasts
update_forecasts_table <- function(con, forecasts) {
  # prepare forecasts for database
  forecasts_df <- forecasts |> 
    mutate(
      .var = variance(value),
      fit_year_month = min(year_month) - 1
    ) |>
    group_by(.model) |> 
    mutate(h = row_number()) |> 
    ungroup() |> 
    select(.model, .model_spec, fit_year_month, year_month, h, .mean, .var) |> 
    as_tibble() |> 
    mutate(
      year_month = as.character(year_month),
      fit_year_month = as.character(fit_year_month)
    )
  
  if (!dbExistsTable(con, "forecasts")) {
    dbWriteTable(con, "forecasts", forecasts_df)
  } else {
    dbAppendTable(con, "forecasts", forecasts_df)
  }
}

make_fable <- function(data, key=NULL) {
  
  forecasts_tsibble <- data |> 
    as_tsibble(key = {{ key }}, index = year_month)
  
  suppressWarnings(as_fable(forecasts_tsibble, response = "value", distribution = "value"))
}