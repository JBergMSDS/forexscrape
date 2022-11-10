##Library call
library(tidyverse)
library(RPostgres)
library(jsonlite)
library(rvest)
library(magrittr)
##API call and basic transformations
f.get_forex_rates <- function(){
  url <- "https://exchange-rates-api.oanda.com/v1/rates/USD.json?api_key=lNqMjgn1qSAtIWmh72xQApCb&quote=CAD&quote=JPY&quote=AUD&quote=EUR&quote=GBP&fields=all&data_set=OANDA"
  response <- read_html(url) %>% html_text() %>% fromJSON()
  quote <- response[3]
  quotes <- quote$quotes
  AUD <- as.data.frame(quotes$AUD)
  AUD %<>% mutate(date = as.Date(date))
  return(AUD)
  JPY <- as.data.frame(quotes$JPY)
  JPY %<>% mutate(date = as.Date(date))
  return(JPY)
  CAD <- as.data.frame(quotes$CAD)
  CAD %<>% mutate(date = as.Date(date))
  return(CAD)
  EUR <- as.data.frame(quotes$EUR)
  EUR %<>% mutate(date = as.Date(date))
  return(EUR)
  GBP <- as.data.frame(quotes$GBP)
  GBP %<>% mutate(date = as.Date(date))
  return(GBP)
}


##Railway Connection##
con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("PGHOST"),
  dbname = Sys.getenv("PGDATABASE"),
  user = Sys.getenv("PGUSER"),
  password = Sys.getenv("PGPASSWORD"),
  port = Sys.getenv("PGPORT")
)

##Infinite loop on 24 hr sleep cycle
while(TRUE){
  f.get_forex_rates()
  ##Table creation and data entry
  dbExecute(con, "CREATE TABLE IF NOT EXISTS forex_rates (
            id SERIAL PRIMARY KEY,
            currency CHAR(3),
            ask NUMERIC,
            bid NUMERIC,
            date DATE,
            midpoint NUMERIC,
            time TIMESTAMPTZ);")
  dbExecute(con, "INSERT INTO forex_rates (currency, ask, bid, date, midpoint, time) VALUES ($1, $2, $3, $4, $5, current_timestamp)", 
            list("AUD", AUD$ask, AUD$bid, AUD$date, AUD$midpoint))
  dbExecute(con, "INSERT INTO forex_rates (currency, ask, bid, date, midpoint, time) VALUES ($1, $2, $3, $4, $5, current_timestamp)", 
            list("JPY", JPY$ask, JPY$bid, JPY$date, JPY$midpoint))
  dbExecute(con, "INSERT INTO forex_rates (currency, ask, bid, date, midpoint, time) VALUES ($1, $2, $3, $4, $5, current_timestamp)", 
            list("CAD", CAD$ask, CAD$bid, CAD$date, CAD$midpoint))
  dbExecute(con, "INSERT INTO forex_rates (currency, ask, bid, date, midpoint, time) VALUES ($1, $2, $3, $4, $5, current_timestamp)", 
            list("EUR", EUR$ask, EUR$bid, EUR$date, EUR$midpoint))
  dbExecute(con, "INSERT INTO forex_rates (currency, ask, bid, date, midpoint, time) VALUES ($1, $2, $3, $4, $5, current_timestamp)", 
            list("GBP", GBP$ask, GBP$bid, GBP$date, GBP$midpoint))
  Sys.sleep(86400)
}
