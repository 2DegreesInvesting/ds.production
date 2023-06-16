
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
# Packages ----

library(dplyr, warn.conflicts = FALSE)
library(readr, warn.conflicts = FALSE)

# Functions ----

mvp_path <- function(...) fs::path_home("Downloads", "mvp", ...)

localize_beach <- function(data) {
  # Localize beach
  lookup_table <- tribble(
        ~where, ~english,
       "beach",     "US",
       "coast",     "US",
    "seashore",     "UK",
     "seaside",     "UK"
  )
  
  left_join(data, lookup_table)
}

celsify_temp <- function(data) {
  mutate(data, temp = if_else(english == "US", f_to_c(temp) * 5/9, temp))
}

f_to_c <- function(x) (x - 32) * 5/9

# Data ----

input_name <- "swim.csv"
input_path <- mvp_path("input", input_name)
input_path
#> /home/rstudio/Downloads/mvp/input/swim.csv

raw <- read_csv(input_path, show_col_types = FALSE)
raw
#> # A tibble: 5 x 3
#>   name  where     temp
#>   <chr> <chr>    <dbl>
#> 1 Adam  beach       95
#> 2 Bess  coast       91
#> 3 Cora  seashore    28
#> 4 Dale  beach       85
#> 5 Evan  seaside     31

# Clean ----


localized <- localize_beach(raw)
#> Joining with `by = join_by(where)`

clean <- celsify_temp(localized)

clean
#> # A tibble: 5 x 4
#>   name  where     temp english
#>   <chr> <chr>    <dbl> <chr>  
#> 1 Adam  beach     19.4 US     
#> 2 Bess  coast     18.2 US     
#> 3 Cora  seashore  28   UK     
#> 4 Dale  beach     16.4 US     
#> 5 Evan  seaside   31   UK

# Save ----

output_path <- mvp_path("output", paste0("clean_", input_name))
output_path
#> /home/rstudio/Downloads/mvp/output/clean_swim.csv

write_csv(clean, output_path)
```
