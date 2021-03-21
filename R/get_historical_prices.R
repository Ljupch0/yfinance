get_historical_price <- function(ticker) {
  pb <- progress_bar(datatype = "Prices", ticker = ticker)
  get_price_proto <- function(ticker, ...) {
    pb$tick(tokens = list(what = ticker))
    jsonlite::flatten(
      jsonlite::fromJSON(
        glue::glue("https://query2.finance.yahoo.com/v10/finance/quoteSummary/{ticker}?modules=price")
      )[[1]][[1]][[1]]
    ) %>%
      select(ends_with(".raw")) %>%
      `names<-`(sub(".raw","", names(.))) %>%
      mutate(
        ticker = ticker,
        date = Sys.Date()
      ) %>%
      select(ticker, date, everything())
  }
  safe_download(vector = ticker, proto_function = get_price_proto)
}
