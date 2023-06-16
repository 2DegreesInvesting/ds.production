#' Localize a place depending on the word used to describe it
#'
#' @param data A data frame.
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' library(tibble)
#'
#' data <- tibble(where = c("beach", "seashore"))
#' localize_beach(data)
localize_beach <- function(data) {
  # style: off
  lookup_table <- tribble(
        ~where, ~english,
       "beach",     "US",
       "coast",     "US",
    "seashore",     "UK",
     "seaside",     "UK"
  )
  # style: on

  left_join(data, lookup_table, by = join_by(where))
}
