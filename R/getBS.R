#' getBS
#'
#' A tidy dataframe of balance sheet data.
#'
#' @param ticker A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param report_type Accepts "quarterly" or "annual". Default is "annual". Both return 4 intervals.
#'
#' @import dplyr
#' @importFrom purrr map2
#'
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' getBS("AAPL")
#'
#' getBS(c("AAPL", "MSFT"), report_type = "quarterly")

getBS <- function(ticker, report_type="annual") {
  pb <- progress_bar(datatype = "Balance Sheets", ticker)
  getBS_proto <- function(ticker, report_type) {
    pb$tick(tokens = list(what = ticker))
    baseURL <- "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
    bsURL <- ifelse(report_type=="quarterly",
                    paste0(baseURL, ticker, "?modules=", "balanceSheetHistoryQuarterly"),
                    paste0(baseURL, ticker, "?modules=", "balanceSheetHistory"))
    df <- json2tidy(bsURL) %>%
      select(endDate.fmt, ends_with(".raw"), -endDate.raw)
    names(df) <- sub(".raw","", names(df))
    names(df) <- sub(".fmt","", names(df))
    df$ticker <- ticker
    df %>%
      dplyr::rename(
        date = endDate
      ) %>%
      dplyr::select(
        ticker, date, everything()
      )
  }
  safe_download(ticker = ticker, report_type = report_type, proto_function = getBS_proto)

}
