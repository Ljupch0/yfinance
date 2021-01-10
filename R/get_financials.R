#' get_financials
#'
#' A single tidy dataframe of income statement, balance sheet, and cash flow data.
#'
#' @param ticker A character vector of stock tickers. Ex. ticker = c("AAPL", "MSFT")
#' @param report_type Accepts "quarterly" or "annual". Default is "annual". Both return 4 intervals.
#'
#' @import dplyr
#'
#' @return Dataframe
#'
#' @export
#'
#' @examples
#' get_financials("AAPL")
#'
#' get_financials(c("AAPL", "MSFT"), report_type = "quarterly")
#'
get_financials <- function (ticker, report_type="annual") {
  ticker <- base::toupper(ticker)
  BS <- get_bs(ticker, report_type)
  CF <- get_cf(ticker, report_type)
  Income <- get_income(ticker, report_type)

  a <- dplyr::full_join(BS, CF)
  b <- dplyr::full_join(a, Income)

  b
}
