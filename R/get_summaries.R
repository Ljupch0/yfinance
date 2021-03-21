#' get_summaries
#'
#' @param ticker A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#'
#' @return Dataframe
#'
#' @import dplyr
#'
#' @export


get_summaries <- function(ticker) {
  pb <- progress_bar(datatype = "Summaries", ticker = ticker)

  get_summaries_proto <- function(ticker, ...) {
    pb$tick(tokens = list(what = ticker))
    data <- jsonlite::flatten(jsonlite::fromJSON(glue::glue("https://query2.finance.yahoo.com/v10/finance/quoteSummary/{ticker}?modules=summaryProfile"))[[1]][[1]][[1]]) %>%
      mutate(
        ticker = ticker,
        download = TRUE
      ) %>%
      select(ticker, everything())
  }

  safe_download(vector = ticker, proto_function = get_summaries_proto)

}




