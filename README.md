
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yfinance for R

{yfinance} returns tidy financial data using the yahoo finance API.

## Install

You can install the released version of yfinance from
[Github](https://github.com/Ljupch0/yfinance) with:

``` r
remotes::install_github("ljupch0/yfinance")
library(yfinance)
```

## Video Tutorial
[![yfinance - Tidy Financial Data in R](http://img.youtube.com/vi/qHFwzY2FXiI/0.jpg)](http://www.youtube.com/watch?v=qHFwzY2FXiI "yfinance - Tidy Financial Data in R")

## Quick Introduction

The functions **get_income**, **get_bs** and **get_cf** return a tidy dataframe of financial statement data for a vector of tickers.
**get_financials** combines all three functions and returns all data for the requested tickers.

The functions take in 2 arguments.  
`ticker` accepts a vector of stock tickers like `c("AAPL", "MSFT", "GOOG")`.  
`report_type` can either be `"quarterly"` or `"annual"`. Note that the free yfinance api returns only four periods, so if `report_type = "annual"` it will return 4 yearly statements, while `report_type = "quarterly"` will return the latest 4 quarterly statements.


