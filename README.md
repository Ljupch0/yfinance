
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yfinance for R

{yfinance} returns tidy Income Statement, Balance Sheet and Cash Flow data, using the yahoo finance API.

## Install

You can install the released version of equityanalysis from
[Github](https://github.com/Ljupch0/yfinance) with:

``` r
remotes::install_github("ljupch0/yfinance")
library(yfinance)
```

## Quick Introduction

The functions **getIncome**, **getBS** and **getCF** return a tidy dataframe of financial statement data for a vector of tickers.
**getFinancials** combines all three functions and returns all data for the requested tickers.

The functions take in 2 arguments.  
`ticker` accepts a vector of stock tickers like `c("AAPL", "MSFT", "GOOG")`.  
`report_type` can either be `"quarterly"` or `"annual"`. Note that the free yfinance api returns only four periods, so if `report_type = "annual"` it will return 4 yearly statements, while `report_type = "quarterly"` will return the latest 4 quarterly statements.


