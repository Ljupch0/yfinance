#' safe_download
#'
#' @param vector A vector of things to be iterated over. Ex. ticker = c("AAPL", "MSFT")
#' @param proto_function A function that needs to run safely and not stop at errors.
#' @param ... Any other parameters that the proto_function accepts.
#'
#' @return Dataframe with errors as attributes.

safe_download <- function(vector, proto_function, ...) {

  safe_function <- purrr::safely(proto_function)

  download <- purrr::transpose(
    purrr::map(.x = vector,
               .f = safe_function,
               ...
    ) )

  data <- bind_rows(download$result)
  error_tickers <- vector[!purrr::map_lgl(download$error, is.null)]
  error_messages <- paste0( error_tickers, ": ", unlist(map(.x = download$error, 1)))



  if (length(error_tickers) != 0) {
    warning(glue::glue("There were ERRORS while downloading data for these items: {paste(error_tickers, collapse = ', ')}.
                       Please check if you have the correct ticker. The vector of errored items and error messages can be accessed as attributes of the returned dataframe - attributes(df)."))
  }
  attr(data, "error_items") <- error_tickers
  attr(data, "error_messages") <- error_messages
  data
}



#' progress_bar
#'
#' @param ticker  A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param datatype The type of data that is accessed.
#'
#' @return Progress Bar.
progress_bar <- function(datatype, ticker, action = "Downloading") {
  progress::progress_bar$new(
    format = glue::glue("  {action} {datatype} :what [:bar] :percent ETA: :eta"),
    total = length(ticker)
  )
}



#' json2tidy
#'
#' @param url The yahoo finance URL to tidy.
#' @importFrom jsonlite fromJSON flatten
#' @importFrom curl curl
#' @import dplyr

json2tidy <- function (url) {
  json <- jsonlite::fromJSON(url)
  df <- jsonlite::flatten(json[[1]][[1]][[1]][[1,1]])
}


