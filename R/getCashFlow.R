#' Get Cash Flow Statement
#'
#' @param ticker The stock ticker of the company as a string.
#' @param format Choose between "raw", "clean" and "tidy" format. "raw" returns the income statement as you see it on yahoo finance, and is the easiest to read. "clean" keeps the same format, but removes empty grouping rows, converts missing data to NA and numbers to numeric. "tidy" makes every item a varaible and every yearly report an observation, so that tidyverse packages can be easily used on the data. Default is "tidy".
#' @param assign Choose between TRUE or FALSE. If TRUE, function output dataframe is assigned as "ticker_cf" to the environment. If FALSE, the function will only return the dataframe and it's up to the user to save it under a name. Default is TRUE.
#'
#' @return A dataframe with cash flow data from the last 4 yearly reports.
#' @export
#'
#' @import tidyr
#' @import dplyr
#' @import stringr
#' @import rvest
#' @importFrom readr parse_number
#'
#' @examples
#' getCashFlow("AAPL")
#' getCashFlow("KO", format = "raw")
#' getCashFlow("MSFT", format = "clean", assign = FALSE)
getCashFlow <- function (ticker, format = "tidy", assign = TRUE) {

  scrape <- function (ticker) {
    df <- NULL
    attempt <- 0
    while(is.null(df) && attempt <= 3 ) {
      attempt <- attempt + 1
      try({
        url <- paste0("https://finance.yahoo.com/quote/",ticker,"/cash-flow")
        page <- xml2::read_html(url)
        nodes <- page %>% rvest::html_nodes(".fi-row")

        for(i in nodes){
          r <- list(i %>% rvest::html_nodes("[title],[data-test='fin-col']") %>% rvest::html_text())
          df <- rbind(df, as.data.frame(matrix(r[[1]], ncol = length(r[[1]]), byrow = TRUE), stringsAsFactors = FALSE))
        }
        matches <- stringr::str_match_all(page %>% rvest::html_node('#Col1-3-Financials-Proxy') %>% rvest::html_text(),'\\d{1,2}/\\d{1,2}/\\d{4}')
        headers <- c('Items',"TTM", matches[[1]][,1])
        names(df) <- headers
        assign("df", df, pos = parent.frame())
      }, silent = TRUE)}

    ifelse(is.null(df),
           stop("After 3 attempts, no data was downloaded from yfinance. Either your ticker is wrong, or you have been downloading a lot of data and yfinance is blocking you."),
           return(df))
  }


  clean <- function (df) {
    df <- df %>%
      dplyr::filter(Items != "Cash flows from operating activities"
                    & Items != "Cash flows from investing activities "
                    & Items != "Cash flows from financing activities")
    df <- df[-c(27),]
    df <- na_if(df,"-")
    df <- df %>%
      dplyr::mutate_at(2:ncol(df), parse_number)
  }


  tidy <- function (df) {
    df <- df %>%
      tidyr::pivot_longer(c(2:ncol(df)), names_to="date") %>%
      tidyr::pivot_wider(names_from = Items)

    df <- df %>%
      dplyr::select(-`Operating Cash Flow`)

    df <- df %>% dplyr::rename(
      "ni" = `Net Income`,
      "da" = `Depreciation & amortization`,
      "deferred_taxes_change"=`Deferred income taxes`,
      "stock_comp" = `Stock based compensation`,
      "working_capital_change" = `Change in working capital`,
      "receivables_change" = `Accounts receivable`,
      "inventory_change" = `Inventory`,
      "payables_change" = `Accounts Payable`,
      "other_working_capital" = `Other working capital`,
      "other_non_cash" = `Other non-cash items`,
      "operating_cf" = `Net cash provided by operating activites`,
      "ppe_investment" = `Investments in property, plant and equipment`,
      "acquisitions" = `Acquisitions, net`,
      "purchases_investments" = `Purchases of investments`,
      "sales_investments" = `Sales/Maturities of investments`,
      "other_investing" = `Other investing activites`,
      "investing_cf" = `Net cash used for investing activites`,
      "debt_repayment" = `Debt repayment`,
      "stock_issued" = `Common stock issued`,
      "stock_repurchased" = `Common stock repurchased`,
      "dividends_paid" = `Dividends Paid`,
      "other_financing" = `Other financing activites`,
      "financing_cf" = `Net cash used privided by (used for) financing activities`,
      "change_cash" = `Net change in cash`,
      "cash_start_period" = `Cash at beginning of period`,
      "cash_end_period" = `Cash at end of period`,
      "capex" = `Capital Expenditure`,
      "fcf" = `Free Cash Flow`
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
           assign(paste0(tolower(ticker),"_cf"), result, envir = .GlobalEnv),
           return(result))

  } else if (format=="clean") {
    result <- clean(scrape(ticker))
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_cf_clean"), result, envir = .GlobalEnv),
           return(result))

  } else if (format=="raw") {
    result <- scrape(ticker)
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_cf_raw"), result, envir = .GlobalEnv),
           return(result))

  } else {
    stop('Format can only be "tidy", "clean", or "raw".')
  }


}
