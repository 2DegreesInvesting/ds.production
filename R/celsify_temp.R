#' Convert the `temp` column from Farenheit to Celsius
#'
#' @param data A data frame.
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' library(tibble)
#'
#' data <- tibble(temp = c(32, 0), english = c("US", "UK"))
#' celsify_temp(data)
celsify_temp <- function(data) {
  stopifnot(hasName(data, "temp"))
  stopifnot(hasName(data, "english"))

  mutate(
    data,
    temp = if_else(.data$english == "US", f_to_c(.data$temp), .data$temp)
  )
}

f_to_c <- function(x) (x - 32) * 5 / 9
