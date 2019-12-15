#' Get Balance Sheet
#'
#' @param ticker The stock ticker of the company as a string.
#' @param format Choose between "raw", "clean" and "tidy" format. "raw" returns the income statement as you see it on yahoo finance, and is the easiest to read. "clean" keeps the same format, but removes empty grouping rows, converts missing data to NA and numbers to numeric. "tidy" makes every item a varaible and every yearly report an observation, so that tidyverse packages can be easily used on the data. Default is "tidy".
#' @param assign Choose between TRUE or FALSE. If TRUE, function output dataframe is assigned as "ticker_bs" to the environment. If FALSE, the function will only return the dataframe and it's up to the user to save it under a name. Default is TRUE.
#'
#' @return A dataframe with balance sheet data from the last 4 yearly reports.
#' @export
#'
#' @import tidyr
#' @import dplyr
#' @import stringr
#' @import rvest
#' @importFrom xml2 read_html
#' @importFrom readr parse_number
#'
#' @examples
#' getBalanceSheet("AAPL")
#' getBalanceSheet("KO", format="raw")
#' getBalanceSheet("MSFT", format="clean", assign=FALSE)
getBalanceSheet <- function (ticker, format="tidy", assign=TRUE) {

  scrape <- function (ticker) {
    df <- NULL
    attempt <- 0
    while(is.null(df) && attempt <= 3 ) {
      attempt <- attempt + 1
      try({
        url <- paste0("https://finance.yahoo.com/quote/",ticker,"/balance-sheet")
        page <- xml2::read_html(url)
        nodes <- page %>% rvest::html_nodes(".fi-row")

        for(i in nodes){
          r <- list(i %>% rvest::html_nodes("[title],[data-test='fin-col']") %>% rvest::html_text())
          df <- rbind(df, as.data.frame(matrix(r[[1]], ncol = length(r[[1]]), byrow = TRUE), stringsAsFactors = FALSE))
        }
        matches <- stringr::str_match_all(page %>% rvest::html_node('#Col1-3-Financials-Proxy') %>% rvest::html_text(),'\\d{1,2}/\\d{1,2}/\\d{4}')
        headers <- c('Items', matches[[1]][,1])
        names(df) <- headers
        assign("df", df, pos = parent.frame())
      }, silent = TRUE)}

    ifelse(is.null(df),
           stop("After 3 attempts, no data was downloaded from yfinance. Either your ticker is wrong,   or you have been downloading a lot of data and yfinance is blocking you."),
           return(df))
  }

  clean <- function (df) {
    df <- df %>%
      dplyr::filter(Items != "Assets"
                    & Items != "Current Assets"
                    & Items != "Cash"
                    & Items != "Non-current assets"
                    & Items != "Property, plant and equipment"
                    & Items != "Liabilities and stockholders' equity"
                    & Items != "Liabilities"
                    & Items != "Current Liabilities"
                    & Items != "Non-current liabilities"
                    & Items != "Stockholders' Equity")
    df <- na_if(df,"-")
    df <- df %>%
      dplyr::mutate_at(2:ncol(df), parse_number)
  }


  tidy <- function (df) {
    df[21, 1] = "deferred_revenue_st"
    df <- df %>%
      tidyr::pivot_longer(c(2:ncol(df)), names_to="date") %>%
      tidyr::pivot_wider(names_from = Items)

    df <- df %>% dplyr::rename(
      "cash_equivalents" = `Cash And Cash Equivalents`,
      "st_investments" = `Short Term Investments`,
      "total_cash" = `Total Cash`,
      "net_receivables" = `Net Receivables`,
      "inventory" = `Inventory`,
      "other_ca" = `Other Current Assets`,
      "total_ca" = `Total Current Assets`,
      "gross_ppe" = `Gross property, plant and equipment`,
      "accumulated_depreciation" = `Accumulated Depreciation`,
      "net_ppe" = `Net property, plant and equipment`,
      "equity_other_investments" = `Equity and other investments`,
      "goodwill" = `Goodwill`,
      "intangibles" = `Intangible Assets`,
      "other_lta" = `Other long-term assets`,
      "total_lta" = `Total non-current assets`,
      "total_assets" = `Total Assets`,
      "total_revenue" = `Total Revenue`,
      "payables" = `Accounts Payable`,
      "taxes_payable" = `Taxes payable`,
      "accrued_liabilities" = `Accrued liabilities`,
      "other_cl" = `Other Current Liabilities`,
      "total_cl" = `Total Current Liabilities`,
      "lt_debt" = `Long Term Debt`,
      "deferred_taxes" = `Deferred taxes liabilities`,
      "deferred_revenue_lt" = `Deferred revenues`,
      "other_lt_liabilities" = `Other long-term liabilities`,
      "total_lt_liabilities" = `Total non-current liabilities`,
      "total_liabilities" = `Total Liabilities`,
      "common_stock" = `Common Stock`,
      "retained_earnings" = `Retained Earnings`,
      "accumulated_other_income" = `Accumulated other comprehensive income`,
      "total_equity" = `Total stockholders' equity`,
      "total_liabilities_equity" = `Total liabilities and stockholders' equity`
    )

    substrEnd <- function(x, n){
      substr(x, nchar(x)-n+1, nchar(x))
    }

    df <- df %>%
      dplyr::mutate(ticker=toupper(ticker),
             year = substrEnd(date,4))

    df <- df %>%
      dplyr::select(ticker, date, year, everything())

    return(df)
  }

  if (assign != TRUE && assign != FALSE) stop("Assign can only be TRUE or FALSE.")

  if (format=="tidy") {
    result <- tidy(clean(scrape(ticker)))
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_bs"), result, envir = .GlobalEnv),
           return(result))
  } else if (format=="clean") {
    result <- clean(scrape(ticker))
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_bs_clean"), result, envir = .GlobalEnv),
           return(result))
  } else if (format=="raw") {
    result <- scrape(ticker)
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_bs_raw"), result, envir = .GlobalEnv),
           return(result))
  } else {
    stop('Format can only be "tidy", "clean", or "raw".')
  }


}
