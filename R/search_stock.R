#' search_stock
#'
#' @param search_term The name, cusip code or stock ticker of a security.
#'
#' @return Search results of securities matching the query. Available data: exchange, shortname, ticker symbol, security type and more.
#' @export
#'
#' @examples
search_stock <- function(search_term) {
  pb <- progress_bar(datatype = "Searching", search_term)

  search_stock_proto <- function(search_term) {
    pb$tick(tokens = list(what = search_term))

    url <- glue::glue("https://query2.finance.yahoo.com/v1/finance/search?q={search_term}")
    jsonlite::fromJSON(url)$quotes %>%
      mutate(search_term = search_term) %>%
      relocate(search_term)
  }
  safe_download(vector = search_term, proto_function = search_stock_proto)

}
