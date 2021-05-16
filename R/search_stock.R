#' search_stock
#'
#' Search for stocks and securities using company names, isin and cusip codes or tickers. Useful to get the exact tickers yahoo finance uses in order to query other financial data.
#'
#' @param search_term The name, cusip code, isin code or stock ticker of a security.
#' @param keep_results Set "top" for the first result per search, or "all" for all search results.
#'
#'
#' @return Search results of securities matching the query. Available data: exchange name, shortname, ticker symbol, security type and more.
#' @export
#'
#' @examples
#' search_stock("Nike", keep_results = "all")
#' search_stock(c("Nike", "adidas"), keep_results = "top")
#' search_stock(search_term = "US4581401001", keep_results = "top")
#' search_stock(search_term = "594918104", keep_results = "top")
search_stock <- function(search_term, keep_results = "all") {
  pb <- progress_bar(action = "Searching", datatype = "term", search_term)


  search_stock_proto <- function(search_term) {
    pb$tick(tokens = list(what = search_term))
    search_term_url <- stringr::str_replace_all(search_term, " ", "%20")
    url <- glue::glue("https://query2.finance.yahoo.com/v1/finance/search?q={search_term_url}")
    results <- jsonlite::fromJSON(url)$quotes

    if (length(results)==0) stop(glue::glue("Your search term '{search_term}' returned 0 results. Try making your search query shorter."))

    output <- results %>%
      mutate(search_term = search_term) %>%
      relocate(search_term)

    if (keep_results == "top") {
      output %>% slice(1)
    } else {
      output
    }

  }
  safe_download(vector = search_term, proto_function = search_stock_proto)

}
