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

  left_join(data, lookup_table)
}
