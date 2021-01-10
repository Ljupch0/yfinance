#' get_income
#'
#' A tidy dataframe of income statement data.
#'
#' @param ticker A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param report_type Accepts "quarterly" or "annual". Default is "annual". Both return 4 intervals.
#'
#' @import dplyr
#' @import purrr
#'
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' get_income("AAPL")
#'
#' get_income(c("AAPL", "MSFT"), report_type = "quarterly")



get_income <- function(ticker, report_type="annual") {
  pb <- progress_bar(datatype = "Income Statements", ticker=ticker)
  get_income_proto <- function(ticker, report_type) {
    pb$tick(tokens = list(what = ticker))
    baseURL <- "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
    incomeURL <- ifelse(report_type=="quarterly",
                        paste0(baseURL, ticker, "?modules=", "incomeStatementHistoryQuarterly"),
                        paste0(baseURL, ticker, "?modules=", "incomeStatementHistory"))
    df <- json2tidy(incomeURL) %>%
      select(endDate.fmt, ends_with(".raw"), -endDate.raw)
    names(df) <- sub(".raw","", names(df))
    names(df) <- sub(".fmt","", names(df))
    df$ticker <- ticker
    df %>%
      dplyr::rename(
        date = endDate
      ) %>%
      select(
        ticker, date, everything()
      )
  }

  safe_download(ticker = ticker, report_type = report_type, proto_function = get_income_proto)

}
