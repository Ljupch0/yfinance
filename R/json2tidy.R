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
