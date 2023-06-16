
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
library(readr, warn.conflicts = FALSE)
library(production)

mvp_path <- function(...) fs::path_home("Downloads", "mvp", ...)

input_name <- "swim.csv"
input_path <- mvp_path("input", input_name)
raw <- read_csv(input_path, show_col_types = FALSE)

localized <- localize_beach(raw)
clean <- celsify_temp(localized)

output_path <- mvp_path("output", paste0("clean_", input_name))
write_csv(clean, output_path)
```
