
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
library(dplyr, warn.conflicts = FALSE)
library(readr, warn.conflicts = FALSE)

mvp_path <- function(...) fs::path_home("Downloads", "mvp", ...)




celsify_temp <- function(data) {
  mutate(data, temp = if_else(english == "US", f_to_c(temp) * 5/9, temp))
}

f_to_c <- function(x) (x - 32) * 5/9



input_name <- "swim.csv"
input_path <- mvp_path("input", input_name)
raw <- read_csv(input_path, show_col_types = FALSE)

localized <- localize_beach(raw)
clean <- celsify_temp(localized)

output_path <- mvp_path("output", paste0("clean_", input_name))
write_csv(clean, output_path)
```
