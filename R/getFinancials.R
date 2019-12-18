#' Get Financial Statements
#'
#' Returns a single tidy dataframe with historical data from the income statement, balance sheet, and cash flow statement.
#'
#' @param ticker The stock ticker of the company as a string, or a vector of stock tickers as strings.
#' @param assign Choose between TRUE or FALSE. If TRUE, the output dataframe is assigned as "financials" to the environment. If FALSE, the function will only return the dataframe and it's up to the user to save it under a name. FALSE is advised when running getFinancials several times, as the previous output dataframes will be overwritten when assign=TRUE. Default is TRUE.
#'
#' @return A dataframe with all financial data from the last 4 yearly reports.
#' @export
#'
#' @import dplyr
#' @importFrom purrr reduce
#'
#' @examples
#' getFinancials("AAPL")
#' getFinancials(c("AAPL", "MSFT"), assign=FALSE)
getFinancials <- function (ticker, assign=TRUE) {
  m <- list()
  for (i in ticker) {
    l <- list()
    l[[1]] <- getIncome(i, format="tidy", assign=FALSE)
    l[[2]] <- getBalanceSheet(i, format="tidy", assign=FALSE)
    l[[3]] <- getCashFlow(i, format="tidy", assign=FALSE)
    m[[match(i, ticker)]] <- purrr::reduce(l, full_join, by = c("ticker", "date", "year")) %>%
      dplyr::select(-ni.y) %>%
      dplyr::rename("ni" = `ni.x`)
    result <- dplyr::bind_rows(m)
  }

  ifelse(assign==TRUE,
         ifelse(length(ticker)==1,
                assign(paste0(tolower(ticker), "_financials"), result, env=.GlobalEnv),
                assign("financials", result, env=.GlobalEnv)),
         return(result))
}
