#' progress_bar
#'
#' @param ticker  A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param datatype The type of data that is accessed.
#'
#' @return Progress Bar.
progress_bar <- function(datatype, ticker) {
  progress::progress_bar$new(
    format = glue::glue("  Downloading {datatype} :what [:bar] :percent ETA: :eta"),
    total = length(ticker)
  )
}
