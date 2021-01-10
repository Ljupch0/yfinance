#' getCF
#'
#' A tidy dataframe of cash flow data.
#'
#' @param ticker A string vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param report_type Accepts "quarterly" or "annual". Default is "annual". Both return 4 intervals.
#'
#' @import dplyr
#' @importFrom purrr map2
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' getCF("AAPL")
#'
#' getCF(c("AAPL", "MSFT"), report_type = "quarterly")

get_cf <- function(ticker, report_type="annual") {
  pb <- progress_bar(datatype = "Cash Flow", ticker = ticker)
  get_cf_proto <- function(ticker, report_type) {
    pb$tick(tokens = list(what = ticker))
    baseURL <- "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
    cfURL <- ifelse(report_type=="quarterly",
                    paste0(baseURL, ticker, "?modules=", "cashflowStatementHistoryQuarterly"),
                    paste0(baseURL, ticker, "?modules=", "cashflowStatementHistory"))

    df <- json2tidy(cfURL) %>%
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
  safe_download(ticker = ticker, report_type = report_type, proto_function = get_cf_proto)
}
