#' search_stock
#'
#' @param search_term The name, cusip code or stock ticker of a security.
#' @param keep_results Set "top" for the first result per search, or "all" for all search results.
#'
#'
#' @return Search results of securities matching the query. Available data: exchange name, shortname, ticker symbol, security type and more.
#' @export
#'
#' @examples
#' search_stock("Nike", keep_results = "top")
#' search_stock(c("Nike", "adidas"), keep_results = "top")
search_stock <- function(search_term, keep_results = "all") {
  pb <- progress_bar(datatype = "Searching", search_term)


  search_stock_proto <- function(search_term) {
    pb$tick(tokens = list(what = search_term))
    search_term_url <- stringr::str_replace_all(search_term, " ", "%20")
    url <- glue::glue("https://query2.finance.yahoo.com/v1/finance/search?q={search_term_url}")
    results <- jsonlite::fromJSON(url)$quotes %>%
      mutate(search_term = search_term) %>%
      relocate(search_term)

    if (keep_results == "top") {
      results %>% slice(1)
    } else {
      results
    }

  }
  safe_download(vector = search_term, proto_function = search_stock_proto)

}
