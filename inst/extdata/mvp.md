
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
# Packages ----

library(dplyr, warn.conflicts = FALSE)
library(readr, warn.conflicts = FALSE)
here <- function(...) fs::path_home("Downloads", "mvp", ...)

# Data ----

input_name <- "swim.csv"
input_path <- here("input", input_name)
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

# Localize beach
lookup_table <- tribble(
      ~where, ~english,
     "beach",     "US",
     "coast",     "US",
  "seashore",     "UK",
   "seaside",     "UK"
)
localized <- raw |> 
  left_join(lookup_table)
#> Joining with `by = join_by(where)`

# Celsify temp
f_to_c <- function(x) (x - 32) * 5/9
clean <- localized |> 
  mutate(temp = if_else(english == "US", f_to_c(temp) * 5/9, temp))

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

output_path <- here("output", paste0("clean_", input_name))
output_path
#> /home/rstudio/Downloads/mvp/output/clean_swim.csv

write_csv(clean, output_path)
```
