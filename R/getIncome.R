#' Get Income Statement
#'
#' Returns historical data from income statements.
#'
#' @param ticker The stock ticker of the company as a string.
#' @param format Choose between "raw", "clean" and "tidy" format. "raw" returns the income statement as you see it on yahoo finance, and is the easiest to read. "clean" keeps the same format, but removes empty grouping rows, converts missing data to NA and numbers to numeric. "tidy" makes every item a varaible and every yearly report an observation, so that tidyverse packages can be easily used on the data. Default is "tidy".
#' @param assign Choose between TRUE or FALSE. If TRUE, function output dataframe is assigned as "ticker_income" to the environment. If FALSE, the function will only return the dataframe and it's up to the user to save it under a name. Default is TRUE.
#'
#' @return A dataframe with income statement data from the last 4 yearly reports.
#' @export
#'
#' @import dplyr
#' @importFrom rvest html_nodes html_node html_text
#' @importFrom stringr str_match_all
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom xml2 read_html
#' @importFrom readr parse_number
#'
#' @examples
#' getIncome("AAPL")
#' getIncome("KO", format="raw")
#' getIncome("MSFT", format="clean", assign=FALSE)
getIncome <- function (ticker, format = "tidy", assign = TRUE) {

  scrape <- function (ticker) {
    df <- NULL
    attempt <- 0
    while(is.null(df) && attempt <= 3 ) {
      attempt <- attempt + 1
      try({
        url <- paste0("https://finance.yahoo.com/quote/",ticker,"/financials")
        page <- xml2::read_html(url)
        nodes <- page %>% rvest::html_nodes(".fi-row")

        for(i in nodes){
          r <- list(i %>% rvest::html_nodes("[title],[data-test='fin-col']") %>% rvest::html_text())
          df <- rbind(df, as.data.frame(matrix(r[[1]], ncol = length(r[[1]]), byrow = TRUE), stringsAsFactors = FALSE))
        }
        matches <- stringr::str_match_all(page %>% rvest::html_node('#Col1-3-Financials-Proxy') %>% rvest::html_text(),'\\d{1,2}/\\d{1,2}/\\d{4}')
        headers <- c('Items','TTM', matches[[1]][,1])
        names(df) <- headers
        assign("df", df, pos = parent.frame())
      }, silent = TRUE)}

    ifelse(is.null(df),
           stop("After 3 attempts, no data was downloaded from yfinance. Either your ticker is wrong, or you have been downloading a lot of data and yfinance is blocking you."),
           return(df))
  }


  clean <- function (df) {
    df<- na_if(df,"-")
    df <- df %>%
      dplyr::mutate_at(2:ncol(df), parse_number)

    df[17, 1] <- "Basic EPS"
    df[18, 1] <- "Diluted EPS"
    df[20, 1] <- "Basic W. Average Shares Outstanding"
    df[21, 1] <- "Diluted W. Average Shares Outstanding"

    df <- df %>% dplyr::filter(Items != "Operating Expenses" & Items != "Reported EPS"  & Items != "Weighted average shares outstanding")
    return(df)
  }


  tidy <- function (df) {
    df <- df %>%
      tidyr::pivot_longer(c(2:ncol(df)), names_to="date") %>%
      tidyr::pivot_wider(names_from = Items)

    substrEnd <- function(x, n){
      substr(x, nchar(x)-n+1, nchar(x))
    }

    df <- df %>%
      dplyr::mutate(ticker=toupper(ticker),
             year = substrEnd(date,4))

    df <- df %>%
      dplyr::select(ticker, date, year, dplyr::everything())


    df <- df %>% dplyr::rename(
      "revenue"=`Total Revenue`,
      "cost_revenue" = `Cost of Revenue`,
      "gross_profit" = `Gross Profit`,
      "rd" = `Research Development`,
      "sga" = `Selling General and Administrative`,
      "operating_expenses" = `Total Operating Expenses`,
      "ebit" = `Operating Income or Loss`,
      "interest_expense" = `Interest Expense`,
      "other_income_net" = `Total Other Income/Expenses Net`,
      "ebt" = `Income Before Tax`,
      "tax" = `Income Tax Expense`,
      "income_operations" = `Income from Continuing Operations`,
      "ni" = `Net Income`,
      "ni_to_shareholders" = `Net Income available to common shareholders`,
      "basic_eps" = `Basic EPS`,
      "diluted_eps" = `Diluted EPS`,
      "basic_w_avg_shares" = `Basic W. Average Shares Outstanding`,
      "diluted_w_avg_shares" = `Diluted W. Average Shares Outstanding`,
      "ebitda" = `EBITDA`
    )
    return(df)
  }

  if (assign != TRUE && assign != FALSE) stop("Assign can only be TRUE or FALSE.")

  if (format=="tidy") {
    result <- tidy(clean(scrape(ticker)))
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_income"), result, envir = .GlobalEnv),
           return(result))

  } else if (format=="clean") {
    result <- clean(scrape(ticker))
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_income_clean"), result, envir = .GlobalEnv),
           return(result))

  } else if (format=="raw") {
    result <- scrape(ticker)
    ifelse(assign == TRUE,
           assign(paste0(tolower(ticker),"_income_raw"), result, envir = .GlobalEnv),
           return(result))

  } else {
    stop('Format can only be "tidy", "clean", or "raw".')
  }

}
