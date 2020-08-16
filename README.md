
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yfinance for R

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/Ljupch0/equityanalysis.svg?branch=master)](https://travis-ci.org/Ljupch0/equityanalysis)
<!-- badges: end -->

The equityanalysis package simplifies the download and analysis of
financial statement data. The data source is yahoo finance.

## Installation

You can install the released version of equityanalysis from
[Github](https://github.com/Ljupch0/equityanalysis) with:

``` r
remotes::install_github("ljupch0/equityanalysis")
library(equityanalysis)
```

## Quick Introduction

The functions **getIncome**, **getBS** and **getCF** return a tidy dataframe of financial statement data for a vector of tickers.
**getFinancials** combines all three functions and returns all data for the requested tickers.

The functions take in 2 arguments. `ticker` accepts a vector of stock tickers like `c("AAPL", "MSFT", "GOOG")`. `report_type` can either be `quarterly` or `annual`. Note that the free yfinance api returns only four periods, so if `report_type = "annual"` it will return 4 yearly statments, while `report_type = "quarterly"` will return the lates 4 quarterly statements.


