#' get_company_names
#'
#' Given a vector of tickers, returns a vector of company names.
#'
#' @param ticker A vector of stock tickers. Ex. c("MSFT", "AAPL")
#'
#' @return
#' @export
#'
#' @examples
#' get_company_names(c("MSFT", "AAPL"))
get_company_names <- function(ticker) {
  pb <- progress_bar(datatype = "Company Names", ticker = ticker)

  get_company_names_proto <- function(ticker, ...) {
    pb$tick(tokens = list(what = ticker))
    name <- jsonlite::fromJSON(
      glue::glue("http://d.yimg.com/autoc.finance.yahoo.com/autoc?query={ticker}&region=1&lang=en")
    )$ResultSet$Result$name[1]

    if (is.null(name)) NA else name
  }
  map_chr(ticker, get_company_names_proto)
}

